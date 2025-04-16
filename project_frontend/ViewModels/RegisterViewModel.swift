import Foundation

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var showingError = false
    @Published var errorMessage = ""
    
    func register(
        username: String,
        email: String,
        password: String,
        confirmPassword: String,
        gender: String,
        birthday: Date,
        height: Double,
        weight: Double,
        startWeight: Double,
        startDate: Date,
        targetWeight: Double,
        targetDate: Date,
        medicalConditions: [String],
        medication: String,
        authViewModel: AuthViewModel
    ) async throws {
        // Validate input
        guard !username.isEmpty else {
            errorMessage = "Please enter a username"
            showingError = true
            throw ValidationError.emptyUsername
        }
        
        guard !email.isEmpty else {
            errorMessage = "Please enter an email"
            showingError = true
            throw ValidationError.emptyEmail
        }
        
        guard !password.isEmpty else {
            errorMessage = "Please enter a password"
            showingError = true
            throw ValidationError.emptyPassword
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showingError = true
            throw ValidationError.passwordMismatch
        }
        
        // TODO: 临时注释掉有问题的代码
        /*
        let detail = UserDetail(
            gender: gender,
            birthday: birthday.ISO8601Format(),
            height: Int(height),
            weight: Int(weight),
            start_weight: Int(startWeight),
            start_date: startDate.ISO8601Format(),
            target_weight: Int(targetWeight),
            target_date: targetDate.ISO8601Format(),
            medical_conditions: medicalConditions.joined(separator: ","),
            medication: medication
        )
        
        // Call AuthViewModel to perform the actual registration
        try await RegisterViewModel.register(
            username: username,
            email: email,
            password: password,
            detail: detail
        )
        */
        
        // 临时打印信息，确认函数被调用
        print("Registration attempted with username: \(username), email: \(email)")
    }
}

enum ValidationError: Error {
    case emptyUsername
    case emptyEmail
    case emptyPassword
    case passwordMismatch
}
