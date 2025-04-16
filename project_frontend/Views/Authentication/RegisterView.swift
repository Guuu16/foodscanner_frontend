import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showDetailView = false
    
    var body: some View {
        VStack(spacing: 25) {
            // 欢迎文本
            VStack(spacing: 8) {
                Text("Create Account")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Join us to start your journey")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.top, 20)
            
            // 输入表单
            VStack(spacing: 16) {
                // 用户名输入框
                TextField("username", text: $username)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.none)
                
                // 邮箱输入框
                TextField("email", text: $email)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                
                // 密码输入框
                SecureField("password", text: $password)
                    .textFieldStyle(CustomTextFieldStyle())
                    .textContentType(.newPassword)
                
                // 确认密码输入框
                SecureField("confirm password", text: $confirmPassword)
                    .textFieldStyle(CustomTextFieldStyle())
                    .textContentType(.newPassword)
            }
            
            // 下一步按钮
            Button(action: {
                showDetailView = true
            }) {
                Text("Next")
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.buttonText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppTheme.buttonPrimary)
                    .cornerRadius(25)
            }
            .disabled(username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || password != confirmPassword)
            .padding(.top, 10)
            
            // 分割线
            HStack {
                Rectangle()
                    .frame(height: 1)
                
                Text("or")
                    .foregroundColor(AppTheme.textSecondary)
                    .font(.footnote)
                
                Rectangle()
                    .frame(height: 1)
            }
            .padding(.vertical)
            
            // 第三方注册按钮
            Button(action: {
                // TODO: 实现 Apple 注册
            }) {
                HStack {
                    Image(systemName: "apple.logo")
                    Text("Continue with Apple")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(AppTheme.buttonSecondary)
                .foregroundColor(AppTheme.buttonTextSecondary)
                .cornerRadius(25)
            }
        }
        .padding(.horizontal, 30)
        .fullScreenCover(isPresented: $showDetailView) {
            RegisterDetailView(email: email, password: password, username: username)
        }
    }
}

#Preview {
    RegisterView()
}
