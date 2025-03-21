import SwiftUI

struct AddAlbumView: View {
    @ObservedObject var addAlbumVM = AddAlbumViewModel()
    @ObservedObject var collectionVM: CollectionViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var searchWorkItem: DispatchWorkItem?  // For debouncing
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if SpotifyAuthManager.shared.accessToken == nil ||
                    SpotifyAuthManager.shared.accessToken?.isEmpty == true {
                    Text("You are not signed into Spotify!")
                        .font(.headline)
                        .padding()
                    Spacer()
                } else {
                    TextField("Enter album name", text: $addAlbumVM.searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onChange(of: addAlbumVM.searchQuery) {
                            searchWorkItem?.cancel()
                            let workItem = DispatchWorkItem {
                                addAlbumVM.performSearch()
                            }
                            searchWorkItem = workItem
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
                        }
                    
                    if addAlbumVM.isLoading {
                        ProgressView()
                    }
                    
                    List(addAlbumVM.searchResults, id: \.id) { album in
                        HStack {
                            if let url = URL(string: album.imageURL), !album.imageURL.isEmpty {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                } placeholder: {
                                    Color.gray
                                }
                                .frame(width: 50, height: 50)
                                .cornerRadius(4)
                            }
                            Text(album.name)
                        }
                        .onTapGesture {
                            // Check for duplicate before adding
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
            .alert("Album Already Added", isPresented: $addAlbumVM.showDuplicateAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}
