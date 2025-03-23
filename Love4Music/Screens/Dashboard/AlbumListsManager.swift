//
//  AlbumListsManager.swift
//  Love4Music
//
//  Created by Martin Ševčík on 20.03.2025.
//

import Foundation
import SwiftUI

// model representing a user-created album list
struct AlbumList: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var albumIDs: [String]
}

// singleton manager for album lists
final class AlbumListsManager: ObservableObject {
    static let shared = AlbumListsManager()
    
    // uses the new CodableAppStorage property wrapper to persist album lists
    @CodableAppStorage("albumLists") var storedLists: [AlbumList] = [
        AlbumList(id: UUID(), name: "Favorites", albumIDs: []),
        AlbumList(id: UUID(), name: "Chill", albumIDs: []),
        AlbumList(id: UUID(), name: "Workout", albumIDs: [])
    ]
    
    // published property for notifying UI updates
    @Published var lists: [AlbumList] = []
    
    init() {
        // load stored lists on initialization
        lists = storedLists
    }
    
    // helper method to update the persisted lists
    private func updateStoredLists() {
        storedLists = lists
    }
    
    // adds an album to a specified list if it isn't already included
    func addAlbum(_ album: SpotifyAlbum, to list: AlbumList) {
        guard let index = lists.firstIndex(where: { $0.id == list.id }) else { return }
        if !lists[index].albumIDs.contains(album.id) {
            lists[index].albumIDs.append(album.id)
            updateStoredLists()
        }
    }
    
    // removes an album from a specific list
    func removeAlbum(_ album: SpotifyAlbum, from list: AlbumList) {
        guard let index = lists.firstIndex(where: { $0.id == list.id }) else { return }
        lists[index].albumIDs.removeAll { $0 == album.id }
        updateStoredLists()
    }
    
    // removes an album from all lists
    func removeAlbum(_ album: SpotifyAlbum) {
        for index in lists.indices {
            lists[index].albumIDs.removeAll { $0 == album.id }
        }
        updateStoredLists()
    }
    
    // creates a new album list with the given name
    func createList(named name: String) {
        let newList = AlbumList(id: UUID(), name: name, albumIDs: [])
        lists.append(newList)
        updateStoredLists()
    }
    
    // deletes a list entirely
    func deleteList(_ list: AlbumList) {
        lists.removeAll { $0.id == list.id }
        updateStoredLists()
    }
}
