//
//  StarRatingView.swift
//  Love4Music
//
//  Created by Martin Ševčík on 20.03.2025.
//

import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Double
    private let starSize: CGFloat = 30
    private let spacing: CGFloat = 4
    
    var body: some View {
        // total width for 5 stars + spacing
        let totalWidth = starSize * 5 + spacing * 4
        
        ZStack(alignment: .leading) {
            // star images
            HStack(spacing: spacing) {
                ForEach(0..<5) { index in
                    let starNumber = Double(index) + 1.0
                    Image(systemName: starType(for: starNumber))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: starSize, height: starSize)
                        .foregroundColor(.lightest)
                }
            }
            .frame(width: totalWidth, height: starSize)
            
            // transparent overlay for gesture detection
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: totalWidth, height: starSize)
                .contentShape(Rectangle()) // ensures taps/drags register
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            // convert x-location to rating
                            let x = value.location.x
                            let chunkWidth = starSize + spacing
                            
                            // +1 because if x=0, user is tapping the first star
                            var newRating = x / chunkWidth + 1
                            
                            // round to nearest half-star
                            newRating = (newRating * 2).rounded() / 2
                            
                            // clamp between 0 and 5
                            rating = min(max(newRating, 0), 5)
                        }
                )
        }
    }
    
    // returns the correct star symbol (full, half, or empty) for a given star index
    private func starType(for star: Double) -> String {
        if rating >= star {
            return "star.fill"
        } else if rating + 0.5 >= star {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}
