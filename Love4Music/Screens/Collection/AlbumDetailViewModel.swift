//
//  AlbumDetailViewModel.swift
//  Love4Music
//
//  Created by Martin Ševčík on 23.03.2025.
//

import SwiftUI


class AlbumDetailViewModel: ObservableObject {
    let album: SpotifyAlbum
    
    // published properties for user notes and rating
    @Published var notes: String = ""
    @Published var rating: Double = 0.0
    
    // private keys based on album id
    private var notesKey: String { "albumNotes_\(album.id)" }
    private var ratingKey: String { "albumRating_\(album.id)" }
    
    // for debouncing notes saving
    private var saveWorkItem: DispatchWorkItem? = nil
    
    init(album: SpotifyAlbum) {
        self.album = album
        loadNotes()
        loadRating()
    }
    
    // open in Spotify
    func openInSpotify(openURL: OpenURLAction) {
        print("Trying to open: \(album.externalURL)")
        guard let spotifyURL = URL(string: album.externalURL), !album.externalURL.isEmpty else {
            print("externalURL is empty or invalid.")
            return
        }
        openURL(spotifyURL)
    }
    
    // load notes
    func loadNotes() {
        notes = UserDefaults.standard.string(forKey: notesKey) ?? ""
    }
    
    func saveNotes() {
        UserDefaults.standard.set(notes, forKey: notesKey)
    }
    
    // load rating
    func loadRating() {
        rating = UserDefaults.standard.double(forKey: ratingKey)
    }
    
    func saveRating() {
        UserDefaults.standard.set(rating, forKey: ratingKey)
    }
    
    // debounce notes saving
    func debounceSaveNotes() {
        saveWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.saveNotes()
        }
        saveWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
}