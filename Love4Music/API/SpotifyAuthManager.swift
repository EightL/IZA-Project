//
//  SpotifyAuthManager.swift
//  Love4Music
//
//  Created by Martin Ševčík on 21.03.2025.
//

import Foundation
import AuthenticationServices
import SwiftUI

// Manages Spotify authentication using ASWebAuthenticationSession.
class SpotifyAuthManager: NSObject, ObservableObject {
    static let shared = SpotifyAuthManager()

    private let clientID = "ede2e46d02b14e1ba734e3c96017de6b"
    private let redirectURI = "vinylvault://callback"
    private let scope = "user-read-private user-top-read"
    private let authURL = "https://accounts.spotify.com/authorize"
    
    @AppStorage("spotifyAccessToken") var storedAccessToken: String?
    
    // published accessToken property that updates storedAccessToken when set
    @Published var accessToken: String? {
        didSet {
            storedAccessToken = accessToken
        }
    }
    
    // initializer
    override init() {
        super.init()
        // initialize the access token from persisted storage
        accessToken = storedAccessToken
    }
    
    
    // initiates Spotify sign-in using ASWebAuthenticationSession
    // it builds the authorization URL with required parameters and starts the session
    func signIn() {
        // construct the authentication URL with query parameters
        let urlString = "\(authURL)?client_id=\(clientID)&response_type=token&redirect_uri=\(redirectURI)&scope=\(scope)&show_dialog=true"
        guard let url = URL(string: urlString) else { return }
        
        // create and start the authentication session
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "vinylvault") { callBackURL, error in
            // ensure there was no error and that a callback URL is returned
            guard error == nil, let callbackURL = callBackURL else { return }
            
            // the access token is returned in the URL fragment
            if let fragment = callbackURL.fragment {
                // parse the fragment into a dictionary
                let params = fragment.components(separatedBy: "&").reduce(into: [String: String]()) { dict, param in
                    let parts = param.components(separatedBy: "=")
                    if parts.count == 2 {
                        dict[parts[0]] = parts[1]
                    }
                }
                // update the accessToken on the main thread
                DispatchQueue.main.async {
                    self.accessToken = params["access_token"]
                    print("Access Token: \(self.accessToken ?? "none")")
                }
            }
        }
        // set the presentation context provider to self
        session.presentationContextProvider = self
        // start the authentication session
        session.start()
    }
    
    // signs out the user by clearing the access token
    func signOut() {
        accessToken = nil
        storedAccessToken = nil
        print("Signed out of Spotify")
    }
}

// provides a presentation anchor (UI window) for the authentication session
extension SpotifyAuthManager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // try to find the key window in the active scene
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return keyWindow
        }
        // fallback to a new UIWindow if key window is not found
        return UIWindow()
    }
}
