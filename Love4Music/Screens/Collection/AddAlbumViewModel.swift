//
//  AddAlbumViewModel.swift
//  Love4Music
//
//  Created by Martin Ševčík on 20.03.2025.
//

import SwiftUI

@MainActor
class AddAlbumViewModel: ObservableObject {
    @Published var searchQuery = ""
    // Stores the results returned from the search.
    @Published var searchResults: [SpotifyAlbum] = []
    @Published var isLoading = false
    @Published var showDuplicateAlert = false
    
    // performs an album search using the Spotify API
    func performSearch() {
        // ensure there's a non-empty search query
        guard !searchQuery.isEmpty else { return }
        
        // set loading flag before initiating the search
        isLoading = true
        
        // call the API manager to perform the search
        SpotifyAPIManager.shared.searchAlbum(query: searchQuery) { result in
            DispatchQueue.main.async {
                // stop the loading indicator when the result is received
                self.isLoading = false
                switch result {
                case .success(let albums):
                    // update search results with the fetched albums
                    self.searchResults = albums
                case .failure(let error):
                    // log the error and clear search results on failure
                    print("Error searching albums: \(error.localizedDescription)")
                    self.searchResults = []
                }
            }
        }
    }
}
