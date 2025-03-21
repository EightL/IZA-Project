import SwiftUI
// MARK: - Statistics ViewModel

class StatisticsViewModel: ObservableObject {
    @Published var topTracks: [SpotifyTrack] = []
    @Published var topArtists: [SpotifyArtist] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    func fetchStatistics() {
        guard SpotifyAuthManager.shared.accessToken != nil else {
            errorMessage = "You are not signed in to Spotify."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        SpotifyAPIManager.shared.getTopTracks { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tracks):
                    self?.topTracks = tracks
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        SpotifyAPIManager.shared.getTopArtists { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let artists):
                    self?.topArtists = artists
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
        }
    }
}

