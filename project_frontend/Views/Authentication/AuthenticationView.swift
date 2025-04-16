import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    @State private var showLogin = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                // Logo
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding(.bottom, 30)
                
                // Login/Register Toggle
                Picker("", selection: $showLogin) {
                    Text("Login").tag(true)
                    Text("Register").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if showLogin {
                    LoginView()
                        .environmentObject(authViewModel)
                        .environmentObject(userProfileViewModel)
                        .onChange(of: authViewModel.isAuthenticated) { newValue in
                            if newValue {
                                dismiss()
                            }
                        }
                } else {
                    RegisterView()
                        .environmentObject(authViewModel)
                }
            }
            .navigationBarHidden(true)
            .padding()
        }
    }
} 

#Preview {
    AuthenticationView()
        .environmentObject(AuthViewModel())
        .environmentObject(UserProfileViewModel())
}
