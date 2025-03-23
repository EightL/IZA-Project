//
//  CreateListView.swift
//  Love4Music
//
//  Created by Martin Ševčík on 22.03.2025.
//

import SwiftUI

struct CreateListView: View {
    @Environment(\.dismiss) var dismiss
    
    // closure for creating the list
    let onCreateList: (String) -> Void
    
    // state for the list name
    @State private var listName: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // title
                Text("Create New Album List")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // using the new shorthand style for rounded border
                TextField("Enter list name", text: $listName)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Spacer()
                
                // create button
                Button {
                    // check if the list name is empty
                    guard !listName.isEmpty else { return }
                    onCreateList(listName)
                    dismiss()
                } label: {
                    Text("Create")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(listName.isEmpty ? Color.gray : Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding([.horizontal, .bottom])
                }
                .disabled(listName.isEmpty)
            }
            .navigationTitle("New List")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.fraction(0.75)])
    }
}
