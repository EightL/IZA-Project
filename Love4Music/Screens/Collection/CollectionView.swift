import SwiftUI

struct CollectionView: View {
    @StateObject private var viewModel = CollectionViewModel()
    @State private var isShowingAddAlbum = false
    
    let columns = [GridItem(.flexible(), spacing: 10),
                   GridItem(.flexible(), spacing: 10),
                   GridItem(.flexible(), spacing: 10)]
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.albums.isEmpty {
                    NoAlbumsYetView()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.albums, id: \.id) { album in
                                VStack {
                                    if let url = URL(string: album.imageURL), !album.imageURL.isEmpty {
                                        AsyncImage(url: url) { image in
                                            image.resizable().scaledToFit()
                                        } placeholder: {
                                            Image("albumMock").resizable().scaledToFit()
                                        }
                                        .frame(width: 120, height: 120)
                                        .cornerRadius(8)
                                    } else {
                                        Image("albumMock")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 120, height: 120)
                                            .cornerRadius(8)
                                    }
                                    
                                    Text(album.name)
                                        .font(.title2)
                                        .lineLimit(1)
                                        .padding(.top, 5)
                                }
                                .onLongPressGesture {
                                    withAnimation {
                                        viewModel.selectedAlbum = album
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Floating plus button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isShowingAddAlbum = true
                        }) {
                            Image(systemName: "plus.rectangle.fill")
                                .resizable()
                                .frame(width: 80, height: 60)
                                .padding()
                        }
                        .padding()
                    }
                }
                
                // Modal for AlbumDetailView
                if let album = viewModel.selectedAlbum {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                viewModel.selectedAlbum = nil
                            }
                        }
                    
                    AlbumDetailView(album: album, onDelete: {
                        viewModel.deleteAlbum(album)
                        withAnimation {
                            viewModel.selectedAlbum = nil
                        }
                    })
                    .frame(maxWidth: 400)
                    .padding()
                    .shadow(radius: 10)
                    .transition(.scale)
                    .zIndex(1)
                }
            }
            .navigationTitle("My collection")
            .sheet(isPresented: $isShowingAddAlbum) {
                AddAlbumView(collectionVM: viewModel)
            }
        }
    }
}
