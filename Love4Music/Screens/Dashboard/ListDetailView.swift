//
//  ListDetailView.swift
//  Love4Music
//
//  Created by Martin Ševčík on 22.03.2025.
//

import SwiftUI

struct ListDetailView: View {
    let albumList: AlbumList
    @ObservedObject var collectionVM: CollectionViewModel
    @ObservedObject var listsManager = AlbumListsManager.shared

    var body: some View {
        // retrieve the latest version of the album list from the manager
        let freshList = listsManager.lists.first(where: { $0.id == albumList.id }) ?? albumList
        // filter the collection's albums to those included in the current list
        let albumsInList = collectionVM.albums.filter { freshList.albumIDs.contains($0.id) }

        return List(albumsInList) { album in
            HStack {
                // load the album cover asynchronously
                if let url = URL(string: album.imageURL), !album.imageURL.isEmpty {
                    CachedAsyncImage(url: url)
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .cornerRadius(4)
                } else {
                    Image("albumMock")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .cornerRadius(4)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // album name
                    Text(album.name)
                        .font(.headline)
                    
                    // retrieve rating and comment from UserDefaults
                    let rating = UserDefaults.standard.double(forKey: "albumRating_\(album.id)")
                    let comment = UserDefaults.standard.string(forKey: "albumNotes_\(album.id)") ?? ""
                    
                    // show rating if available (non-zero)
                    if rating != 0 {
                        Text("Rating: \(String(format: "%.1f", rating))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // show comment if available (non-empty)
                    if !comment.isEmpty {
                        Text("Comment: \(comment)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // conditionally show the "Open in Spotify" button if an external URL is provided
                if !album.externalURL.isEmpty {
                    Button {
                        openInSpotify(album)
                    } label: {
                        Image("spotifyIcon")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                }
            }
            // enable a swipe-to-delete action on the trailing edge
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    // remove the album from the current list
                    listsManager.removeAlbum(album, from: freshList)
                } label: {
                    Label("Remove", systemImage: "trash")
                }
            }
        }
        .listStyle(.insetGrouped)
        // set the navigation title to the name of the album list
        .navigationTitle(albumList.name)
    }
    
    // helper function to open the album's external Spotify link
    // if the URL is valid, this will open it in the appropriate app (Spotify or Safari)
    private func openInSpotify(_ album: SpotifyAlbum) {
        guard let url = URL(string: album.externalURL) else { return }
        UIApplication.shared.open(url)
    }
}
