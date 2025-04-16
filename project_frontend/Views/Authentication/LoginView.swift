import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showForgotPassword = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 25) {
            // 欢迎文本
            VStack(spacing: 8) {
                Text("Food Scanner")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Discipline for a Better Life")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.top, 20)
            
            // 输入表单
            VStack(spacing: 16) {
                TextField("email/username", text: $email)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                
                SecureField("password", text: $password)
                    .textFieldStyle(CustomTextFieldStyle())
                    .textContentType(.password)
            }
            
            // 忘记密码按钮
            HStack {
                Spacer()
                Button("forgot password?") {
                    showForgotPassword = true
                }
                .foregroundColor(AppTheme.textSecondary)
            }
            
            // 登录按钮
            Button(action: {
                Task {
                    isLoading = true
                    do {
                        await authViewModel.login(user_or_email: email, password: password)
                        if let error = authViewModel.errorMessage {
                            errorMessage = error
                            showError = true
                            isLoading = false
                        } else {
                            // 登录成功后立即获取用户资料
                            if let userId = authViewModel.userId {
                                print("Login successful, fetching user profile for userId: \(userId)")
                                await userProfileViewModel.fetchUserProfile(userId: userId)
                            } else {
                                print("Login successful but userId is nil")
                            }
                            isLoading = false
                        }
                    } catch {
                        errorMessage = error.localizedDescription
                        showError = true
                        isLoading = false
                    }
                }
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppTheme.primary)
                        .cornerRadius(8)
                } else {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppTheme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .disabled(isLoading)
            
            Spacer()
        }
        .padding(.horizontal)
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}

// 自定义输入框样式
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(AppTheme.inputBackground)
            .cornerRadius(12)
    }
}

// MARK: - Previews
#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
        .environmentObject(UserProfileViewModel())
}
