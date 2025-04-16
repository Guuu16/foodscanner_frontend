import SwiftUI

struct RegisterDetailView: View {
    let email: String
    let password: String
    let username: String
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var registerViewModel = RegisterViewModel()
    
    @State private var gender = "Male"
    @State private var birthday = Date()
    @State private var height = ""
    @State private var weight = ""
    @State private var targetWeight = ""
    @State private var targetDate = Date()
    @State private var selectedMedicalConditions: Set<String> = []
    @State private var selectedMedications: Set<String> = []
    @State private var showError = false
    @State private var showSuccess = false
    @State private var navigateToLogin = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    let genderOptions = ["Male", "Female", "Other"]
    let medicalConditionOptions = [
        "None",
        "Diabetes",
        "Hypertension",
        "Heart Disease",
        "Asthma",
        "Allergies",
        "Other"
    ]
    
    let medicationOptions = [
        "None",
        "Blood Pressure Medication",
        "Diabetes Medication",
        "Heart Medication",
        "Asthma Medication",
        "Allergy Medication",
        "Other"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Information")) {
                    Picker("Gender", selection: $gender) {
                        ForEach(genderOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                    
                    TextField("Height (cm)", text: $height)
                        .keyboardType(.decimalPad)
                    
                    TextField("Current Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Goals")) {
                    TextField("Target Weight (kg)", text: $targetWeight)
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Target Date", selection: $targetDate, displayedComponents: .date)
                }
                
                Section(header: Text("Medical Conditions")) {
                    ForEach(medicalConditionOptions, id: \.self) { condition in
                        Toggle(condition, isOn: Binding(
                            get: { selectedMedicalConditions.contains(condition) },
                            set: { isSelected in
                                if isSelected {
                                    selectedMedicalConditions.insert(condition)
                                    if condition == "None" {
                                        selectedMedicalConditions = ["None"]
                                    } else {
                                        selectedMedicalConditions.remove("None")
                                    }
                                } else {
                                    selectedMedicalConditions.remove(condition)
                                }
                            }
                        ))
                    }
                }
                
                Section(header: Text("Medications")) {
                    ForEach(medicationOptions, id: \.self) { medication in
                        Toggle(medication, isOn: Binding(
                            get: { selectedMedications.contains(medication) },
                            set: { isSelected in
                                if isSelected {
                                    selectedMedications.insert(medication)
                                    if medication == "None" {
                                        selectedMedications = ["None"]
                                    } else {
                                        selectedMedications.remove("None")
                                    }
                                } else {
                                    selectedMedications.remove(medication)
                                }
                            }
                        ))
                    }
                }
                
                Section {
                    Button(action: {
                        Task {
                            await register()
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Complete Registration")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .listRowBackground(AppTheme.primary)
                    .disabled(isLoading)
                }
            }
            .navigationTitle("Complete Registration")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Registration Failed", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .alert("Registration Successful", isPresented: $showSuccess) {
                Button("OK") {
                    navigateToLogin = true
                }
            } message: {
                Text("Your account has been created successfully. Please login to continue.")
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
    
    private func register() async {
        guard let heightDouble = Double(height.replacingOccurrences(of: ",", with: ".")),
              let weightDouble = Double(weight.replacingOccurrences(of: ",", with: ".")),
              let targetWeightDouble = Double(targetWeight.replacingOccurrences(of: ",", with: ".")) else {
            errorMessage = "Please enter valid numbers for height, weight and target weight"
            showError = true
            return
        }
        
        // 验证输入范围
        guard heightDouble > 0 && heightDouble < 300 else {
            errorMessage = "Please enter a valid height (0-300 cm)"
            showError = true
            return
        }
        
        guard weightDouble > 0 && weightDouble < 500 else {
            errorMessage = "Please enter a valid weight (0-500 kg)"
            showError = true
            return
        }
        
        guard targetWeightDouble > 0 && targetWeightDouble < 500 else {
            errorMessage = "Please enter a valid target weight (0-500 kg)"
            showError = true
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        
        let medicalConditionsJson = selectedMedicalConditions.contains("None") ? "[]" : 
            try? String(data: JSONEncoder().encode(Array(selectedMedicalConditions).filter { $0 != "None" }), encoding: .utf8) ?? "[]"
            
        let medicationsJson = selectedMedications.contains("None") ? "[]" :
            try? String(data: JSONEncoder().encode(Array(selectedMedications).filter { $0 != "None" }), encoding: .utf8) ?? "[]"
        
        let request = RegisterRequest(
            username: username,
            password: password,
            email: email,
            gender: gender,
            birthday: dateFormatter.string(from: birthday),
            height: heightDouble,
            weight: weightDouble,
            startWeight: weightDouble,
            startDate: dateFormatter.string(from: Date()),
            targetWeight: targetWeightDouble,
            targetDate: dateFormatter.string(from: targetDate),
            medicalConditions: medicalConditionsJson ?? "[]",
            medication: medicationsJson ?? "[]"
        )
        
        isLoading = true
        do {
            print("\nFinal request:")
            if let requestData = try? JSONEncoder().encode(request),
               let requestString = String(data: requestData, encoding: .utf8) {
                print(requestString)
            }
            
            let response = try await APIService.register(request: request)
            print("\nRegister success:")
            if let responseData = try? JSONEncoder().encode(response),
               let responseString = String(data: responseData, encoding: .utf8) {
                print(responseString)
            }
            
            isLoading = false
            showSuccess = true  // 显示成功提示
            
        } catch {
            isLoading = false
            if let apiError = error as? APIError {
                errorMessage = apiError.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
            print("\nRegister error: \(errorMessage)")
            showError = true
        }
    }
}

struct RegisterDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterDetailView(email: "test@example.com", password: "password", username: "testuser")
    }
}