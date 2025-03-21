//
//  AddAlbumViewModel.swift
//  Love4Music
//
//  Created by Martin Ševčík on 20.03.2025.
//

import SwiftUI

class AddAlbumViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [SpotifyAlbum] = []
    @Published var isLoading = false
    @Published var showDuplicateAlert = false
    
    func performSearch() {
        guard !searchQuery.isEmpty else { return }
        isLoading = true
        SpotifyAPIManager.shared.searchAlbum(query: searchQuery) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let albums):
                    self.searchResults = albums
                case .failure(let error):
                    print("Error searching albums: \(error.localizedDescription)")
                    self.searchResults = []
                }
            }
        }
    }
}
