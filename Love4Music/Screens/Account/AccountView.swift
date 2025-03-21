import SwiftUI

struct AccountView: View {
    @ObservedObject var authManager = SpotifyAuthManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            if let token = authManager.accessToken, !token.isEmpty {
                Text("Already signed in to Spotify")
                    .font(.headline)
                Button("Sign out of Spotify") {
                    authManager.signOut()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Sign in with Spotify") {
                    authManager.signIn()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}



#Preview {
    AccountView()
}
