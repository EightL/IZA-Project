//
//  ContentView.swift
//  Love4Music
//
//  Created by Martin Ševčík on 19.03.2025.
//

import SwiftUI

struct MainTabView: View {
    // initial tab selection
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // statistics tab - shows spotify statistics (top artists, top tracks, top genres, etc.)
            StatisticsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar")
                }
                .tag(0)
            
            // collection tab - shows a grid of the users manually added albums
            CollectionView()
                .tabItem {
                    Label("Collection", systemImage: "square.grid.2x2")
                }
                .tag(1)
            
            // dashboard tab - spotify signing handling, custom lists of albums, charts
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "list.dash")
                }
                .tag(2)
        }
        .accentColor(.lightest)
        .background(Color.dark)
    }
}

#Preview {
    MainTabView()
}
