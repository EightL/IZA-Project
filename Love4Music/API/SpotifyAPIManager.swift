import Foundation

struct SpotifyAlbum: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let images: [SpotifyImage]
    
    // Computed property to return the first image URL (or an empty string if none available)
    var imageURL: String {
        images.first?.url ?? ""
    }
}

struct SpotifyImage: Codable, Equatable {
    let url: String
}

struct SpotifySearchResponse: Decodable {
    let albums: AlbumsContainer
}

struct AlbumsContainer: Decodable {
    let items: [SpotifyAlbum]
}

class SpotifyAPIManager {
    static let shared = SpotifyAPIManager()
    private init() {}
    
    private var accessToken: String {
        return SpotifyAuthManager.shared.accessToken ?? ""
    }
    
    func searchAlbum(query: String, completion: @escaping (Result<[SpotifyAlbum], Error>) -> Void) {
        guard !accessToken.isEmpty else {
            completion(.failure(NSError(domain: "NoAccessToken", code: 401, userInfo: nil)))
            return
        }
        
        let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.spotify.com/v1/search?q=\(queryEncoded)&type=album"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 400, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 404, userInfo: nil)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
                completion(.success(response.albums.items))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
