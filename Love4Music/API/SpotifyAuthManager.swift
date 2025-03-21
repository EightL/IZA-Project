//
//  SpotifyAuthManager.swift
//  Love4Music
//
//  Created by Martin Ševčík on 20.03.2025.
//

import Foundation
import AuthenticationServices
import SwiftUI

class SpotifyAuthManager: NSObject, ObservableObject {
    static let shared = SpotifyAuthManager()
    
    private let clientID = "ede2e46d02b14e1ba734e3c96017de6b"
    private let redirectURI = "vinylvault://callback"
    private let scope = "user-read-private" // add other scopes if needed
    private let authURL = "https://accounts.spotify.com/authorize"

    @AppStorage("spotifyAccessToken") var storedAccessToken: String?
    @Published var accessToken: String? {
        didSet {
            storedAccessToken = accessToken
        }
    }
    
    override init() {
        super.init()
        accessToken = storedAccessToken
    }

    func signIn() {
        let urlString = "\(authURL)?client_id=\(clientID)&response_type=token&redirect_uri=\(redirectURI)&scope=\(scope)&show_dialog=true"
        guard let url = URL(string: urlString) else { return }
        
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "vinylvault") {callBackURL, error in
            guard error == nil, let callbackURL = callBackURL else { return }
            
            if let fragment = callbackURL.fragment {
                let params = fragment.components(separatedBy: "&").reduce(into: [String: String]()) { dict, param in
                    let parts = param.components(separatedBy: "=")
                    if parts.count == 2 {
                        dict[parts[0]] = parts[1]
                    }
                }
                DispatchQueue.main.async {
                    self.accessToken = params["access_token"]
                    print("Access Token: \(self.accessToken ?? "none")")
                }
            }
        }
        session.presentationContextProvider = self
        session.start()
    }
    
    func signOut() {
        accessToken = nil
        storedAccessToken = nil
        print("Signed out of Spotify")
    }

}

extension SpotifyAuthManager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return keyWindow
        }
        return UIWindow() // fallback if key window not found
    }
}

