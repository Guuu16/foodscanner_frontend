import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var userProfileViewModel = UserProfileViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
                    .environmentObject(userProfileViewModel)
            } else {
                NavigationView {
                    AuthenticationView()
                        .environmentObject(authViewModel)
                        .environmentObject(userProfileViewModel)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
