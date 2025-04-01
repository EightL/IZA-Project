//
//  CollectionView.swift
//  Love4Music
//
//  Created by Martin Ševčík on 19.03.2025.
//
import SwiftUI

struct CollectionView: View {
    @StateObject var viewModel: CollectionViewModel
    @State private var isShowingAddAlbum = false

    // three-column grid
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    // custom initializer ( dependency injection of a view model )
    init(viewModel: CollectionViewModel = CollectionViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // if there are no albums, display a placeholder view
                if viewModel.albums.isEmpty {
                    NoAlbumsYetView()
                } else {
                    // display albums in a scrollable grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(viewModel.albums, id: \.id) { album in
                                VStack(spacing: 5) {
                                    // load album image asynchronously
                                    if let url = URL(string: album.imageURL), !album.imageURL.isEmpty {
                                        CachedAsyncImage(url: url)
                                            .scaledToFit()
                                            .frame(width: 114, height: 114)
                                            .cornerRadius(8)
                                    } else {
                                        // fallback image if no valid URL exists
                                        Image("albumMock")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 114, height: 114)
                                            .cornerRadius(8)
                                    }
                                    
                                    // display album name below the image
                                    Text(album.name)
                                        .font(.caption)
                                        .lineLimit(1)
                                }
                                // set the selected album when tapped
                                .onTapGesture {
                                    viewModel.selectedAlbum = album
                                }
                            }
                        }
                        .padding()
                    }
                    .id(viewModel.refreshTrigger)
                }
                
                // floating plus button in the bottom-right corner
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isShowingAddAlbum = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .padding()
                                .background(Circle().fill(Color.accentColor))
                                .foregroundColor(.darkest)
                        }
                        .padding()
                    }
                }
            }
            // set the navigation title
            .navigationTitle("My Collection")
            // present the AddAlbumView when the plus button is tapped
            .sheet(isPresented: $isShowingAddAlbum) {
                AddAlbumView(collectionVM: viewModel)
            }
            // present AlbumDetailView when an album is selected
            .sheet(item: $viewModel.selectedAlbum) { album in
                AlbumDetailView(
                    album: album,
                    onDelete: {
                        viewModel.deleteAlbum(album)
                    }
                )
                .id(album.id)
            }
        }
    }
}
