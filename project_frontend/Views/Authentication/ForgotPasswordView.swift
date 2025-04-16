import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("reset password")
                    .font(.title)
                    .padding(.top)
                
                Text("please enter your registered email, we will send you a link to reset your password")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                TextField("email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal)
                
                Button("send reset link") {
                    // TODO: 实现发送重置密码邮件的逻
                }
            }
            .padding()
        }
    }
} 

#Preview {
    ForgotPasswordView()
}