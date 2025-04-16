//import SwiftUI
//
//struct ProfileItem<Action: View>: View {
//    let title: String
//    let value: String
//    let action: () -> Action
//    
//    init(title: String, value: String, @ViewBuilder action: @escaping () -> Action) {
//        self.title = title
//        self.value = value
//        self.action = action
//    }
//    
//    var body: some View {
//        HStack {
//            Text(title)
//                .foregroundColor(AppTheme.textPrimary)
//            
//            Spacer()
//            
//            Text(value)
//                .foregroundColor(AppTheme.textSecondary)
//            
//            action()
//        }
//        .padding(.horizontal)
//        .frame(height: 44)
//    }
//}
//
//#Preview {
//    VStack {
//        ProfileItem(title: "Name", value: "John Doe") {
//            Image(systemName: "chevron.right")
//        }
//        
//        ProfileItem(title: "Email", value: "john@example.com") {
//            Image(systemName: "chevron.right")
//        }
//    }
//    .padding()
//}
