//
//  SpotifyAPIManager.swift
//  Love4Music
//
//  Created by Martin Ševčík on 21.03.2025.
//

import Foundation
import SwiftUI

// enum representing different time ranges for top tracks and artists
enum TimeRange: String, CaseIterable, Identifiable {
    case shortTerm = "short_term"
    case mediumTerm = "medium_term"
    case longTerm = "long_term"
    
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .shortTerm: return "Last 4 Weeks"
        case .mediumTerm: return "Last 6 Months"
        case .longTerm: return "All Time"
        }
    }
}

// MARK: - Models

// represents a Spotify album with associated images and external URLs
struct SpotifyAlbum: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let images: [SpotifyImage]
    
    // a dictionary of external URLs provided by Spotify
    let external_urls: [String: String]?
    
    // returns the URL string of the first image if available; otherwise, returns an empty string
    var imageURL: String {
        images.first?.url ?? ""
    }
    
    // returns a Spotify link for the album
    // if an external URL is provided, it uses that; otherwise, it constructs a default web link using the album’s ID
    var externalURL: String {
        if let link = external_urls?["spotify"], !link.isEmpty {
            return link
        } else {
            return "https://open.spotify.com/album/\(id)"
        }
    }
}

// represents an image provided by Spotify
struct SpotifyImage: Codable, Equatable {
    let url: String
}

// represents a Spotify artist, including optional images and genres
struct SpotifyArtist: Codable, Equatable, Identifiable {
    let id: String
    let name: String
    let href: String
    let uri: String
    let external_urls: [String: String]?
    let images: [SpotifyImage]?
    let genres: [String]?
}

// represents a Spotify track, including its album and contributing artists
struct SpotifyTrack: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let album: SpotifyAlbum
    let artists: [SpotifyArtist]
    // duration in milliseconds
    let durationMs: Int?
    let explicit: Bool
    let popularity: Int
}

// represents the response structure for a top tracks API call
struct SpotifyTopTracksResponse: Decodable {
    let items: [SpotifyTrack]
    let total: Int
    let limit: Int
    let offset: Int
    let next: String?
    let previous: String?
}

// a generic container for responses with an "items" array
// this can be used for multiple types of items
struct SpotifyItemsResponse<Item: Decodable>: Decodable {
    let items: [Item]
}

// represents a search response for albums
struct SpotifySearchResponse: Decodable {
    let albums: AlbumsContainer
}

// contains a list of Spotify albums returned from a search query
struct AlbumsContainer: Decodable {
    let items: [SpotifyAlbum]
}

// MARK: - API Manager

// manages communication with Spotify's API
class SpotifyAPIManager {
    // shared instance for easy access
    static let shared = SpotifyAPIManager()
    private init() {} // private initializer to enforce singleton usage
    
    // retrieves the current access token from the Spotify authentication manager
    private var accessToken: String {
        return SpotifyAuthManager.shared.accessToken ?? ""
    }
    
    // fetches the user's top tracks
    func getTopTracks(timeRange: String, limit: Int = 50, completion: @escaping (Result<[SpotifyTrack], Error>) -> Void) {
        // ensure we have an access token
        guard !accessToken.isEmpty else {
            completion(.failure(NSError(domain: "NoAccessToken", code: 401, userInfo: nil)))
            return
        }
        // construct the URL string using the provided parameters
        let urlString = "https://api.spotify.com/v1/me/top/tracks?limit=\(limit)&time_range=\(timeRange)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 400, userInfo: nil)))
            return
        }
        
        // prepare the URL request with the appropriate Authorization header
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // execute the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            // handle errors from the network
            if let error = error {
                print("Error fetching top tracks: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // ensure data was returned
            guard let data = data else {
                print("No data returned for top tracks request.")
                completion(.failure(NSError(domain: "NoData", code: 404, userInfo: nil)))
                return
            }
            
            do {
                // Set up the decoder with a key decoding strategy to convert snake_case to camelCase.
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                // Decode the response.
                let response = try decoder.decode(SpotifyTopTracksResponse.self, from: data)
                completion(.success(response.items))
            } catch {
                print("Failed to decode top tracks: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Decoding error - JSON: \(jsonString)")
                }
                completion(.failure(error))
            }
        }.resume()
    }
    
    // fetches the user's top artists
    func getTopArtists(timeRange: String, completion: @escaping (Result<[SpotifyArtist], Error>) -> Void) {
        guard !accessToken.isEmpty else {
            completion(.failure(NSError(domain: "NoAccessToken", code: 401, userInfo: nil)))
            return
        }
        // construct the URL string using the provided parameters
        let urlString = "https://api.spotify.com/v1/me/top/artists?time_range=\(timeRange)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 400, userInfo: nil)))
            return
        }
        // prepare the URL request with the appropriate Authorization header
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            // ensure data was returned
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 404, userInfo: nil)))
                return
            }
            do {
                // Decode the response using a generic container for items.
                let response = try JSONDecoder().decode(SpotifyItemsResponse<SpotifyArtist>.self, from: data)
                completion(.success(response.items))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // searches for albums matching a query
    func searchAlbum(query: String, completion: @escaping (Result<[SpotifyAlbum], Error>) -> Void) {
        guard !accessToken.isEmpty else {
            completion(.failure(NSError(domain: "NoAccessToken", code: 401, userInfo: nil)))
            return
        }
        
        // percent-encode the query string
        let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.spotify.com/v1/search?q=\(queryEncoded)&type=album"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 400, userInfo: nil)))
            return
        }
        // prepare the URL request with the appropriate Authorization header
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // execute the network request
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            // ensure data was returned
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 404, userInfo: nil)))
                return
            }
            
            do {
                // decode the search response
                let response = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
                completion(.success(response.albums.items))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
