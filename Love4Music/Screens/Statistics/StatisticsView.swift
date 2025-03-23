//
//  StatisticsView.swift
//  Love4Music
//
//  Created by Martin Ševčík on 23.03.2025.
//

import SwiftUI
import Charts

// defines the different segments (tabs) available in the statistics view
enum StatisticsSegment: String, CaseIterable, Identifiable {
    case tracks = "Tracks"
    case artists = "Artists"
    case genres = "Genres"
    case albums = "Albums"
    
    var id: Self { self }
}

// defines the sort options for album statistics
enum AlbumSortOption: String, CaseIterable, Identifiable {
    case count = "Count"
    case weighted = "Weighted"
    
    var id: Self { self }
}

// displays user statistics for different categories (tracks, artists, genres, albums)
// using segmented controls and lists
struct StatisticsView: View {
    // the view model that handles fetching and processing the statistics data
    @StateObject private var viewModel = StatisticsViewModel()
    // state variable to track the currently selected statistics segment
    @State private var selectedSegment: StatisticsSegment = .tracks
    // state variable to track the album sort option for the album segment
    @State private var albumSortOption: AlbumSortOption = .count

    var body: some View {
        NavigationStack {
            VStack {
                // main segmented control for statistics
                Picker("Statistics", selection: $selectedSegment) {
                    ForEach(StatisticsSegment.allCases) { segment in
                        Text(segment.rawValue).tag(segment)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // time range segmented control
                Picker("Time Range", selection: $viewModel.selectedTimeRange) {
                    ForEach(TimeRange.allCases) { range in
                        Text(range.displayName).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                // when the time range changes, fetch the statistics data
                .onChange(of: viewModel.selectedTimeRange) {
                    viewModel.fetchStatistics()
                }
                
                // content based on the selected segment
                Group {
                    switch selectedSegment {
                    case .tracks:
                        // display a list of top tracks
                        List(viewModel.displayTopTracks) { track in
                            HStack(spacing: 10) {
                                // album cover image (loaded asynchronously)
                                if let url = URL(string: track.album.imageURL),
                                   !track.album.imageURL.isEmpty {
                                    CachedAsyncImage(url: url)
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    // fallback image if album image URL is empty or invalid
                                    Image("albumMock")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                
                                // track details: track name, album, and artists
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(track.name)
                                        .font(.headline)
                                    Text("Album: \(track.album.name)")
                                        .font(.subheadline)
                                    Text("Artists: \(track.artists.map { $0.name }.joined(separator: ", "))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        
                    case .artists:
                        // display a list of top artists
                        List(viewModel.topArtists) { artist in
                            HStack(spacing: 10) {
                                // artist image or fallback if not available
                                if let imageURLString = artist.images?.first?.url,
                                   let url = URL(string: imageURLString) {
                                    CachedAsyncImage(url: url)
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.gray)
                                }
                                
                                // artist name
                                Text(artist.name)
                                    .font(.headline)
                            }
                            .padding(.vertical, 4)
                        }
                        
                    case .genres:
                        // display a list of top genres sorted by score
                        List(viewModel.sortedTopGenres, id: \.genre) { item in
                            HStack {
                                Text(item.genre)
                                    .font(.headline)
                                Spacer()
                                Text(String(format: "%.2f", item.score))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        
                    case .albums:
                        // display a list of top albums
                        // here you can choose to use the albumSortOption to switch sorting
                        // (for example, count vs. weighted), if your view model supports it
                        List(viewModel.allTopTracks.topAlbumsWeighted(), id: \.album.id) { item in
                            HStack(spacing: 10) {
                                // album cover image
                                if let url = URL(string: item.album.imageURL),
                                   !item.album.imageURL.isEmpty {
                                    CachedAsyncImage(url: url)
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    Image("albumMock")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                
                                // album details: album name and score
                                VStack(alignment: .leading) {
                                    Text(item.album.name)
                                        .font(.headline)
                                    Text(String(format: "Score: %.2f", item.score))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Your Statistics")
            // when the view appears, fetch the latest statistics
            .onAppear {
                viewModel.fetchStatistics()
            }
        }
    }
}
