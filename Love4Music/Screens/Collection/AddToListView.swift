//
//  AddToListView.swift
//  Love4Music
//
//  Created by Martin Ševčík on 22.03.2025.
//

import SwiftUI


struct AddToListView: View {
    let album: SpotifyAlbum
    // access the shared AlbumListsManager to manage album lists
    @ObservedObject var listsManager = AlbumListsManager.shared
    // environment dismiss function to close the view
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            // list of album lists available for adding/removing the album
            List(listsManager.lists) { list in
                Button {
                    // if the album is already in the list, remove it; otherwise, add it
                    if list.albumIDs.contains(album.id) {
                        listsManager.removeAlbum(album, from: list)
                    } else {
                        listsManager.addAlbum(album, to: list)
                    }
                } label: {
                    HStack {
                        Text(list.name)
                        Spacer()
                        // show a checkmark if the album is in this list
                        if list.albumIDs.contains(album.id) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .navigationTitle("Add to List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        // present the view as a sheet covering 75% of the screen height
        .presentationDetents([.fraction(0.75)])
    }
}

