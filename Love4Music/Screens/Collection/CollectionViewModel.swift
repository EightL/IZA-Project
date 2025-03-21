import Foundation
import SwiftUI

class CollectionViewModel: ObservableObject {
    @Published var albums: [SpotifyAlbum] = []
    @Published var selectedAlbum: SpotifyAlbum? = nil
    
    private let albumsKey = "savedAlbums"
    
    init() {
        loadAlbums()
    }
    
    func loadAlbums() {
        if let data = UserDefaults.standard.data(forKey: albumsKey) {
            do {
                albums = try JSONDecoder().decode([SpotifyAlbum].self, from: data)
            } catch {
                print("Failed to load albums: \(error.localizedDescription)")
            }
        }
    }
    
    func saveAlbums() {
        do {
            let data = try JSONEncoder().encode(albums)
            UserDefaults.standard.set(data, forKey: albumsKey)
        } catch {
            print("Failed to save albums: \(error.localizedDescription)")
        }
    }
    
    func addAlbum(_ album: SpotifyAlbum) {
        // Avoid duplicates before adding
        if !albums.contains(where: { $0.id == album.id }) {
            albums.append(album)
            saveAlbums()
        }
    }
    
    func deleteAlbum(_ album: SpotifyAlbum) {
        albums.removeAll { $0.id == album.id }
        saveAlbums()
    }
}
