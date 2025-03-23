//
//  DashboardStatisticsView.swift
//  Love4Music
//
//  Created by Martin Ševčík on 22.03.2025.
//

import SwiftUI
import Charts

// data model for a rating distribution entry
struct RatingData: Identifiable {
    let id = UUID()
    let rating: Double
    let count: Int
}

// data model for album list statistics
struct AlbumListData: Identifiable {
    let id = UUID()
    let listName: String
    let count: Int
}

struct DashboardStatisticsView: View {
    // using a dedicated view model for statistics logic
    @ObservedObject var viewModel: DashboardStatisticsViewModel

    var body: some View {
        TabView {
            // chart 1: rating distribution
            VStack {
                Text("Average Rating: \(String(format: "%.2f", viewModel.averageRating))")
                    .font(.title2)
                    .padding(.top)
                Chart(viewModel.ratingDistribution) { data in
                    BarMark(
                        x: .value("Rating", data.rating),
                        y: .value("Count", data.count)
                    )
                }
                .frame(height: 200)
                .padding(.horizontal)
                .padding(.bottom)
            }
            
            // chart 2: album lists overview
            VStack {
                Text("Album Lists Overview")
                    .font(.title2)
                    .padding(.top)
                Chart(viewModel.albumListDistribution) { data in
                    BarMark(
                        x: .value("List", data.listName),
                        y: .value("Count", data.count)
                    )
                }
                .frame(height: 180)
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        // using the newer shorthand for page-style TabView
        .tabViewStyle(.page(indexDisplayMode: .automatic))
    }
}
