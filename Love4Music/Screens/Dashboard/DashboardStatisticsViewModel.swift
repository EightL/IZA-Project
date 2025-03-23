//
//  DashboardStatisticsViewModel.swift
//  Love4Music
//
//  Created by Martin Ševčík on 23.03.2025.
//

import SwiftUI
import Charts

@MainActor
final class DashboardStatisticsViewModel: ObservableObject {
    private let collectionVM: CollectionViewModel
    private let listsManager: AlbumListsManager
    
    init(collectionVM: CollectionViewModel, listsManager: AlbumListsManager) {
        self.collectionVM = collectionVM
        self.listsManager = listsManager
    }
    
    // rating distribution - frequency distribution of album ratings
    var ratingDistribution: [RatingData] {
        var frequency: [Double: Int] = [:]
        for album in collectionVM.albums {
            let rating = UserDefaults.standard.double(forKey: "albumRating_\(album.id)")
            guard rating != 0 else { continue }
            let rounded = (rating * 2).rounded() / 2
            frequency[rounded, default: 0] += 1
        }
        return frequency
            .map { RatingData(rating: $0.key, count: $0.value) }
            .sorted { $0.rating < $1.rating }
    }
    
    // computing the average album rating
    var averageRating: Double {
        let total = collectionVM.albums.reduce(0.0) { sum, album in
            sum + UserDefaults.standard.double(forKey: "albumRating_\(album.id)")
        }
        return collectionVM.albums.isEmpty ? 0 : total / Double(collectionVM.albums.count)
    }
    
    // album list distribution - statistics on album lists
    var albumListDistribution: [AlbumListData] {
        listsManager.lists.map { list in
            AlbumListData(listName: list.name, count: list.albumIDs.count)
        }
    }
}
