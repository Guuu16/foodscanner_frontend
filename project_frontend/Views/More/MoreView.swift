import SwiftUI

// MARK: - More View
struct MoreView: View {
    @EnvironmentObject var viewModel: UserProfileViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingLogoutAlert = false
    @State private var isLoggingOut = false
    @State private var shouldNavigateToLogin = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    if let profile = viewModel.userProfile {
                        NavigationLink(destination: UserProfileView()) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(profile.username)
                                        .font(.headline)
                                    Text(profile.email)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.leading, 8)
                            }
                            .padding(.vertical, 8)
                        }
                    } else if viewModel.isLoading {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                            
                            Text("Loading...")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    } else {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.red)
                            
                            Text("Loading failed")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        .padding(.vertical, 8)
                        .onTapGesture {
                            Task {
                                if let userId = authViewModel.userId {
                                    print("Retrying to fetch profile for userId: \(userId)")
                                    await viewModel.fetchUserProfile(userId: userId)
                                } else {
                                    print("Cannot fetch profile: userId is nil")
                                }
                            }
                        }
                    }
                }
                
                // Settings Components Preview
                Section {
                    NavigationLink(destination: AppearanceSettingsView()) {
                        MoreOptionRow(icon: "paintbrush", title: "Appearance Settings", color: .blue)
                    }
                    // NavigationLink(destination: DietaryPreferencesView()) {
                    //     MoreOptionRow(icon: "fork.knife", title: "Dietary Preferences", color: .green)
                    // }
                    NavigationLink(destination: FeedbackView()) {
                        MoreOptionRow(icon: "envelope", title: "Feedback", color: .orange)
                    }
                    // NavigationLink(destination: GoalsSettingsView()) {
                    //     MoreOptionRow(icon: "chart.bar", title: "Goals Settings", color: .teal)
                    // }
                    NavigationLink(destination: HelpCenterView()) {
                        MoreOptionRow(icon: "questionmark.circle", title: "Help Center", color: .purple)
                    }
                    NavigationLink(destination: LanguageSettingsView()) {
                        MoreOptionRow(icon: "globe", title: "Language Settings", color: .yellow)
                    }
                    // NavigationLink(destination: NotificationSettingsView()) {
                    //     MoreOptionRow(icon: "bell", title: "Notification Settings", color: .cyan)
                    // }
                    // NavigationLink(destination: PrivacySettingsView()) {
                    //     MoreOptionRow(icon: "lock", title: "Privacy Settings", color: .pink)
                    // }
                }
                
                // Logout Section
                Section {
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                            Text("Logout")
                                .foregroundColor(.red)
                        }
                    }
                    .disabled(isLoggingOut)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("More")
            .alert("Logout", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    Task {
                        await logout()
                    }
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            .fullScreenCover(isPresented: $shouldNavigateToLogin) {
                AuthenticationView()
                    .environmentObject(authViewModel)
            }
        }
        .onAppear {
            if viewModel.userProfile == nil {
                Task {
                    if let userId = authViewModel.userId {
                        print("Fetching profile on appear for userId: \(userId)")
                        await viewModel.fetchUserProfile(userId: userId)
                    } else {
                        print("Cannot fetch profile on appear: userId is nil")
                    }
                }
            }
        }
    }
    
    private func logout() async {
        isLoggingOut = true
        do {
            if let userId = authViewModel.userId {
                print("Logging out for userId: \(userId)")
                let response = try await APIService.logout(userId: userId)
                if response.code == 200 {
                    // 清除用户数据
                    UserDefaults.standard.removeObject(forKey: "access_token")
                    // 更新认证状态并跳转到登录页
                    await MainActor.run {
                        authViewModel.userId = nil
                        authViewModel.isAuthenticated = false
                        viewModel.userProfile = nil
                        shouldNavigateToLogin = true
                    }
                } else {
                    print("Logout failed: \(response.message)")
                }
            }
        } catch {
            print("Logout error: \(error.localizedDescription)")
        }
        isLoggingOut = false
    }
}

// MARK: - More Option Row
struct MoreOptionRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            Text(title)
            Spacer()
        }
    }
}

// MARK: - Previews
struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MoreView()
                .environmentObject(UserProfileViewModel())
                .environmentObject(AuthViewModel())
                .previewDisplayName("More View")
        }
    }
}
