import SwiftUI

struct ProfileHeader: View {
    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(AppTheme.secondaryBackground)
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(20)
                        .foregroundColor(AppTheme.primary)
                )
            
            Text("Profile")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
        }
        .padding(.vertical, 20)
    }
}

#Preview {
    ProfileHeader()
        .padding()
        .background(AppTheme.background)
}
