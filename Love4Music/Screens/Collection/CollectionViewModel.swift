//
//  CollectionViewModel.swift
//  Love4Music
//
//  Created by Martin Ševčík on 19.03.2025.
//

import Foundation
import SwiftUI


class CollectionViewModel: ObservableObject {
    // published properties to update the UI when the data changes
    @Published var albums: [SpotifyAlbum] = []
    @Published var selectedAlbum: SpotifyAlbum? = nil
    @Published var refreshTrigger = UUID()
    
    // key used for storing albums in UserDefaults
    private let albumsKey = "savedAlbums"
    
    // initializer that loads any previously saved albums
    init() {
        loadAlbums()
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(refreshData),
                    name: Notification.Name("DataChanged"),
                    object: nil
        )
    }
    
    @objc private func refreshData() {
            refreshTrigger = UUID()
            loadAlbums() // Optional: reload from storage
        }
    
    // loads albums from UserDefaults
    func loadAlbums() {
        if let data = UserDefaults.standard.data(forKey: albumsKey) {
            do {
                // decode the saved data into an array of SpotifyAlbum objects
                albums = try JSONDecoder().decode([SpotifyAlbum].self, from: data)
            } catch {
                print("Failed to load albums: \(error.localizedDescription)")
            }
        }
    }
    
    // saves the current albums array to UserDefaults
    func saveAlbums() {
        do {
            let data = try JSONEncoder().encode(albums)
            UserDefaults.standard.set(data, forKey: albumsKey)
        } catch {
            print("Failed to save albums: \(error.localizedDescription)")
        }
    }
    
    // adds a new album if it doesn't already exist in the collection
    func addAlbum(_ album: SpotifyAlbum) {
        // check for duplicates by comparing album IDs
        if !albums.contains(where: { $0.id == album.id }) {
            albums.append(album)
            saveAlbums()
        }
    }
    
    // deletes an album from the collection and updates any associated album lists
    func deleteAlbum(_ album: SpotifyAlbum) {
        albums.removeAll { $0.id == album.id }
        saveAlbums()
        AlbumListsManager.shared.removeAlbum(album)
    }
}
