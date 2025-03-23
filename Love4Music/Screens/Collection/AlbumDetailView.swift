//
//  AlbumDetailView.swift
//  Love4Music
//
//  Created by Martin Ševčík on 20.03.2025.
//

import SwiftUI

// extension to dismiss the keyboard
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct AlbumDetailView: View {
    let album: SpotifyAlbum
    let onDelete: () -> Void
    
    @StateObject private var viewModel: AlbumDetailViewModel
    @State private var showingDeleteAlert = false
    @State private var isShowingAddToListSheet = false
    
    // keyboard focus state for the comment field
    @FocusState private var isNotesFieldFocused: Bool
    
    // environment dismiss function to close the view
    @Environment(\.dismiss) private var dismiss
    // inject the openURL environment value
    @Environment(\.openURL) private var openURL
    
    // custom initializer to set up the view model
    init(album: SpotifyAlbum, onDelete: @escaping () -> Void) {
        self.album = album
        self.onDelete = onDelete
        _viewModel = StateObject(wrappedValue: AlbumDetailViewModel(album: album))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // top bar with Spotify and Close buttons
                HStack {
                    Button {
                        viewModel.openInSpotify(openURL: openURL)
                    } label: {
                        Image("spotifyIcon")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                // album cover
                Group {
                    if let url = URL(string: album.imageURL), !album.imageURL.isEmpty {
                        CachedAsyncImage(url: url)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .cornerRadius(8)
                    } else {
                        ProgressView()
                    }
                }
                
                // album title
                Text(album.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                // star rating view
                StarRatingView(rating: $viewModel.rating)
                    .onChange(of: viewModel.rating) {
                        viewModel.saveRating()
                    }
                
                // comment section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Comment")
                        .font(.subheadline)
                    TextEditor(text: $viewModel.notes)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary))
                        .focused($isNotesFieldFocused)
                        .onChange(of: viewModel.notes) {
                            viewModel.debounceSaveNotes()
                        }
                }
                
                // bottom buttons (add to list & delete)
                HStack {
                    Button("Add to List") {
                        isShowingAddToListSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Spacer()
                    
                    Button("Delete") {
                        showingDeleteAlert = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
            .padding(16)
            .contentShape(Rectangle())
            .onTapGesture { hideKeyboard() }
            .sheet(isPresented: $isShowingAddToListSheet) {
                AddToListView(album: album)
            }
            .alert("Delete from your collection?", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    onDelete()
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            }
            .presentationDetents([.fraction(0.75)])
        }
    }
}
