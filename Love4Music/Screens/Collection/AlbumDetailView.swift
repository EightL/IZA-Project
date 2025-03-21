//
//  AlbumDetailView.swift
//  Love4Music
//
//  Created by Martin Ševčík on 20.03.2025.
//

import SwiftUI

let sampleAlbum = SpotifyAlbum(
    id: "1",
    name: "Sample Album",
    images: [SpotifyImage(url: "https://via.placeholder.com/300")]
)

struct AlbumDetailView: View {
    let album: SpotifyAlbum
    
    let onDelete: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack (spacing: 20) {
            NavigationStack{
                if let url = URL(string: album.imageURL), !album.imageURL.isEmpty {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                    } placeholder: {
                        Image("albumMock")
                            .resizable()
                    }
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(8)
                } else {
                    Image("albumMock")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(8)
                }
                
                Text(album.name)
                    .font(.title)
                    .fontWeight(.semibold)
                    
                
                Spacer()
                
                Button("Delete Album", role: .destructive) {
                    onDelete()
                    dismiss()
                }
                .padding()
                .buttonStyle(.bordered)
                .tint(.red)
                
                .navigationTitle("Album Details")
            }
        }
        .frame(width: 300, height: 525)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 40)
        .navigationTitle("Album Details")
        
    }
}

#Preview {
    AlbumDetailView(album: sampleAlbum, onDelete: {})
}
