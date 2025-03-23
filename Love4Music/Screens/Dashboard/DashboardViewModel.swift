//
//  DashboardViewModel.swift
//  Love4Music
//
//  Created by Martin Ševčík on 23.03.2025.
//

import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    
    private let authManager = SpotifyAuthManager.shared
    private let listsManager = AlbumListsManager.shared
    let collectionVM = CollectionViewModel()
    
    @Published var isSignedIn: Bool = false
    @Published var albumLists: [AlbumList] = []
    // Data to be shared via the share sheet.
    @Published var shareItems: [Any] = []
    // Controls the presentation of the share sheet.
    @Published var showShareSheet: Bool = false
    
    
    // when the view model is created, initialize the published properties from the managers
    init() {
        // load the current album lists from the lists manager
        self.albumLists = listsManager.lists
        // set the sign-in state based on whether there's a valid token
        self.isSignedIn = hasValidToken()
    }
    
    // triggers the sign-in process via the auth manager
    func signIn() {
        authManager.signIn()
        // update the sign-in state after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isSignedIn = self.hasValidToken()
        }
    }
    
    // triggers the sign-out process and updates the sign-in state
    func signOut() {
        authManager.signOut()
        isSignedIn = hasValidToken()
    }
    
    // helper function that checks if the current access token is valid
    private func hasValidToken() -> Bool {
        // check if the token exists and is non-empty
        guard let token = authManager.accessToken else { return false }
        return !token.isEmpty
    }
    
    // creates a new album list with the provided name
    func createList(named name: String) {
        listsManager.createList(named: name)
        // update the local albumLists array to reflect changes
        albumLists = listsManager.lists
    }
    
    // deletes an album list and updates the local property
    func deleteList(_ list: AlbumList) {
        listsManager.deleteList(list)
        albumLists = listsManager.lists
    }
    
    // exports the contents of an album list as a formatted text output
    func exportList(_ list: AlbumList) {
        // filter the albums that belong to the selected list
        let albumsInList = collectionVM.albums.filter { list.albumIDs.contains($0.id) }
        
        // prepare the export output string
        var output = "Album List Export 📋🎧\n\n"
        output += "List: \(list.name)\n"
        output += "Albums in list: \(albumsInList.count)\n"
        output += "=================================\n\n"
        
        // loop through each album and append its details
        for album in albumsInList {
            // retrieve any user notes or ratings stored in UserDefaults
            let comment = UserDefaults.standard.string(forKey: "albumNotes_\(album.id)") ?? ""
            let rating = UserDefaults.standard.double(forKey: "albumRating_\(album.id)")
            
            output += "Album 💿: \(album.name)\n"
            output += "  ⭐️ Rating: \(String(format: "%.1f", rating))\n"
            output += "  📝 Note: \(comment.isEmpty ? "[No comment]" : comment)\n\n"
        }
        
        output += "=================================\n"
        
        // set the shareItems property to the generated output
        self.shareItems = [output]
        // show the share sheet to allow the user to share/export the data
        self.showShareSheet = true
    }
    
    // provides the list of albums from the collection view model for use in the UI
    var collectionAlbums: [SpotifyAlbum] {
        collectionVM.albums
    }
}
