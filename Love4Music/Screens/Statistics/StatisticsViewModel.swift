import SwiftUI

@MainActor
final class StatisticsViewModel: ObservableObject {
    
    // holds the full list of top tracks for computations
    @Published var allTopTracks: [SpotifyTrack] = []
    // a subset of top tracks to display (e.g., top 20)
    @Published var displayTopTracks: [SpotifyTrack] = []
    
    @Published var topTracks: [SpotifyTrack] = []
    @Published var topArtists: [SpotifyArtist] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var topAlbums: [(album: SpotifyAlbum, count: Int)] = []
    
    // the selected time range for which statistics are fetched
    @Published var selectedTimeRange: TimeRange = .mediumTerm
    
    // computed properties
    var computedTopAlbums: [(album: SpotifyAlbum, score: Double)] {
        allTopTracks.topAlbumsWeighted()
    }
    
    // fetches top tracks and top artists from Spotify
    func fetchStatistics() {
        print("fetchStatistics called")
        
        // check for a valid access token
        guard SpotifyAuthManager.shared.accessToken != nil else {
            errorMessage = "You are not signed in to Spotify."
            print("No access token available!")
            return
        }
        
        // begin loading and clear any previous error
        isLoading = true
        errorMessage = nil
        
        // use a dispatch group to synchronize parallel network calls
        let dispatchGroup = DispatchGroup()
        
        // fetch top tracks
        dispatchGroup.enter()
        SpotifyAPIManager.shared.getTopTracks(timeRange: selectedTimeRange.rawValue, limit: 50) { [weak self] result in
            DispatchQueue.main.async {
                print("Received top tracks result")
                switch result {
                case .success(let tracks):
                    print("Successfully fetched \(tracks.count) tracks")
                    // store the full list for computations
                    self?.allTopTracks = tracks
                    // for display purposes, show only the top 20 tracks
                    self?.displayTopTracks = Array(tracks.prefix(20))
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Error fetching tracks: \(error)")
                }
                dispatchGroup.leave()
            }
        }
        
        // fetch top artists
        dispatchGroup.enter()
        SpotifyAPIManager.shared.getTopArtists(timeRange: selectedTimeRange.rawValue) { [weak self] result in
            DispatchQueue.main.async {
                print("Received top artists result")
                switch result {
                case .success(let artists):
                    print("Successfully fetched \(artists.count) artists")
                    self?.topArtists = artists
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Error fetching artists: \(error)")
                }
                dispatchGroup.leave()
            }
        }
        
        // once both fetch operations complete, update the loading state
        dispatchGroup.notify(queue: .main) {
            print("All fetch operations complete")
            self.isLoading = false
        }
    }
    
    // compute and sort genres based on weighted scores
    var sortedTopGenres: [(genre: String, score: Double)] {
        var genreScores = [String: Double]()
        let totalArtists = topArtists.count
        // enumerate over artists to assign weights based on ranking
        for (index, artist) in topArtists.enumerated() {
            // higher ranked artists receive a higher weight
            let weight = Double(totalArtists - index) / Double(totalArtists)
            for genre in artist.genres ?? [] {
                genreScores[genre, default: 0] += weight
            }
        }
        // sort genres by score in descending order and return them
        return genreScores.sorted { $0.value > $1.value }
            .map { (genre: $0.key, score: $0.value) }
    }
}

// array extension for top albums
extension Array where Element == SpotifyTrack {
    // returns an array of tuples where each tuple contains an album and its weighted score
    // the score is computed by assigning higher weights to tracks that appear earlier in the list
    func topAlbumsWeighted() -> [(album: SpotifyAlbum, score: Double)] {
        let totalCount = self.count
        var albumScores = [String: (album: SpotifyAlbum, score: Double)]()
        
        for (index, track) in self.enumerated() {
            // compute weight: first track gets weight 1.0, subsequent tracks get proportionally lower weight
            let weight = Double(totalCount - index) / Double(totalCount)
            // calculate track score using duration (converted to seconds)
            let trackScore = weight * (Double(track.durationMs ?? 0) / 1000.0)
            
            let albumId = track.album.id
            if let existing = albumScores[albumId] {
                albumScores[albumId] = (album: track.album, score: existing.score + trackScore)
            } else {
                albumScores[albumId] = (album: track.album, score: trackScore)
            }
        }
        
        // return the albums sorted by their weighted score in descending order
        return albumScores.values.sorted { $0.score > $1.score }
    }
}
