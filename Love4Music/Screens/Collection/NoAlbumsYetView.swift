//
//  NoAlbumsYetView.swift
//  Love4Music
//
//  Created by Martin Ševčík on 20.03.2025.
//

import SwiftUI

struct NoAlbumsYetView: View {
    var body: some View {
        NavigationStack{
            
            VStack{
                
                
                
                Text("Looks like you dont have any albums added yet!\n Click the plus button to add an album")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(50)
                    .padding(.top, 100)
                    .multilineTextAlignment(.center)
                    .navigationTitle("My collection")
                
                Spacer()
            }
            
            
        }
    }
}

#Preview {
    NoAlbumsYetView()
}
