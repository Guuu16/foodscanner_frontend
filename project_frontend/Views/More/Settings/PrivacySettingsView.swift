import SwiftUI

struct PrivacySettingsView: View {
    @AppStorage("profileVisibility") private var profileVisibility = true
    @AppStorage("shareProgress") private var shareProgress = true
    @AppStorage("dataCollection") private var dataCollection = true
    
    var body: some View {
        Form {
            Section(header: Text("Profile Privacy")) {
                Toggle("Public Profile", isOn: $profileVisibility)
                    .onChange(of: profileVisibility) { newValue in
                        // Update privacy settings on server
                    }
                Toggle("Share Progress", isOn: $shareProgress)
            }
            
            Section(header: Text("Data Collection"), footer: Text("We collect data to improve your experience and provide personalized recommendations.")) {
                Toggle("Allow Data Collection", isOn: $dataCollection)
            }
            
            Section {
                NavigationLink("Manage Data") {
                    ManageDataView()
                }
                Button("Delete Account") {
                    // Show delete account confirmation
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Privacy")
    }
}

struct ManageDataView: View {
    var body: some View {
        List {
            Button("Export Data") {
                // Handle data export
            }
            Button("Clear Search History") {
                // Clear search history
            }
            Button("Clear Cache") {
                // Clear app cache
            }
        }
        .navigationTitle("Manage Data")
    }
}
