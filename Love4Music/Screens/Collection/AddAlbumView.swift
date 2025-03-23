//
//  AddAlbumView.swift
//  Love4Music
//
//  Created by Martin Ševčík on 20.03.2025.
//

import SwiftUI

struct AddAlbumView: View {
    @ObservedObject var addAlbumVM = AddAlbumViewModel()
    @ObservedObject var collectionVM: CollectionViewModel
    // environment value to dismiss the view
    @Environment(\.dismiss) var dismiss
    
    // for debouncing search input
    @State private var searchWorkItem: DispatchWorkItem?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // check if user is signed into Spotify
                if SpotifyAuthManager.shared.accessToken == nil ||
                    SpotifyAuthManager.shared.accessToken?.isEmpty == true {
                    Text("You are not signed into Spotify!")
                        .font(.headline)
                        .padding()
                    Spacer()
                } else {
                    // text field for entering album name to search
                    TextField("Enter album name", text: $addAlbumVM.searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onChange(of: addAlbumVM.searchQuery) {
                            // cancel any previous search task
                            searchWorkItem?.cancel()
                            // create a new work item to perform the search
                            let workItem = DispatchWorkItem {
                                addAlbumVM.performSearch()
                            }
                            searchWorkItem = workItem
                            // delay the search for 0.5 seconds (debouncing)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
                        }
                    
                    // show a loading indicator while searching
                    if addAlbumVM.isLoading {
                        ProgressView()
                    }
                    
                    // display search results as a list
                    List(addAlbumVM.searchResults, id: \.id) { album in
                        AlbumRowView(album: album)
                            .onTapGesture {
                                // check for duplicate before adding
                                if collectionVM.albums.contains(where: { $0.id == album.id }) {
                                    addAlbumVM.showDuplicateAlert = true
                                } else {
                                    collectionVM.addAlbum(album)
                                    dismiss()
                                }
                            }
                    }
                    .listStyle(PlainListStyle())
                }
                Spacer()
            }
            .navigationTitle("Add new album")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            // alert if the album is already added
            .alert("Album Already Added", isPresented: $addAlbumVM.showDuplicateAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}

// row view to display album information
struct AlbumRowView: View {
    let album: SpotifyAlbum
    
    var body: some View {
        HStack {
            // display album image with a placeholder if needed
            if let url = URL(string: album.imageURL), !album.imageURL.isEmpty {
                CachedAsyncImage(url: url, placeholder: Image("albumMock"))
                    .frame(width: 50, height: 50)
                    .cornerRadius(4)
            } else {
                Image("albumMock")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(4)
            }
            // display album name
            Text(album.name)
        }
    }
}
