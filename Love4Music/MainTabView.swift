//
//  ContentView.swift
//  Love4Music
//
//  Created by Martin Ševčík on 19.03.2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // First tab
            StatisticsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar")
                }

            // Second tab
            CollectionView()
                .tabItem {
                    Label("Collection", systemImage: "square.grid.2x2")
                }

            // Third tab
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
        }
        .accentColor(.accentColor)
    }
}

#Preview {
    MainTabView()
}
