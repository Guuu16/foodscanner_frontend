import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var userId: Int?
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var accessToken: String = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    init() {
        // 从 UserDefaults 恢复用户会话
        if let token = UserDefaults.standard.string(forKey: "access_token"),
           let userId = UserDefaults.standard.integer(forKey: "user_id") as Int?,
           let username = UserDefaults.standard.string(forKey: "username"),
           let email = UserDefaults.standard.string(forKey: "email") {
            
            // 先设置基本信息
            self.accessToken = token
            self.userId = userId
            self.username = username
            self.email = email
            
            // 验证token有效性
            Task {
                do {
                    // 尝试获取用户信息来验证token
                    _ = try await APIService.getUserProfile(userId: userId)
                    await MainActor.run {
                        self.isAuthenticated = true
                    }
                } catch {
                    // token无效，清除所有用户数据
                    await MainActor.run {
                        self.clearUserData()
                    }
                }
            }
        }
    }
    
    private func clearUserData() {
        // 清除内存中的数据
        self.accessToken = ""
        self.userId = nil
        self.username = ""
        self.email = ""
        self.isAuthenticated = false
        
        // 清除 UserDefaults 中的数据
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "user_id")
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "email")
    }
    
    func login(user_or_email: String, password: String) async {
        print("Login attempt - user_or_email: \(user_or_email)")
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let response = try await APIService.login(email: user_or_email, password: password)
            
            await MainActor.run {
                // 先设置认证状态
                self.isAuthenticated = true
                
                // 然后更新其他用户数据
                self.userId = response.data.user_id
                self.username = response.data.username
                self.email = response.data.email
                self.accessToken = response.data.access_token
                
                // 保存用户数据到 UserDefaults
                UserDefaults.standard.set(response.data.access_token, forKey: "access_token")
                UserDefaults.standard.set(response.data.user_id, forKey: "user_id")
                UserDefaults.standard.set(response.data.username, forKey: "username")
                UserDefaults.standard.set(response.data.email, forKey: "email")
                
                print("Login successful - userId: \(self.userId ?? -1), username: \(self.username), isAuthenticated: \(self.isAuthenticated)")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                self.isAuthenticated = false
            }
        }
        
        await MainActor.run {
            self.isLoading = false
        }
    }
    
    func logout() {
        print("Logging out - Previous state: isAuthenticated: \(isAuthenticated), userId: \(String(describing: userId))")
        // 清除用户数据
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "user_id")
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "email")
        
        // 重置状态
        userId = nil
        username = ""
        email = ""
        accessToken = ""
        isAuthenticated = false
        
        print("Logout complete - New state: isAuthenticated: \(isAuthenticated), userId: \(String(describing: userId))")
    }
}
