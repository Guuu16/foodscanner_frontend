// MARK: - Models
struct UserProfile: Codable, Identifiable {
    let id: Int
    let username: String
    let email: String
    let isActive: Bool
    let createdAt: String
    let updatedAt: String?
    let detail: UserDetail
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case detail
    }
}

struct UserDetail: Codable {
    let gender: String?
    let birthday: String
    let height: Int
    let weight: Int
    let startWeight: Int
    let startDate: String
    let targetWeight: Int
    let targetDate: String
    let medicalConditions: [String]
    let medication: String?
    
    enum CodingKeys: String, CodingKey {
        case gender
        case birthday
        case height
        case weight
        case startWeight = "start_weight"
        case startDate = "start_date"
        case targetWeight = "target_weight"
        case targetDate = "target_date"
        case medicalConditions = "medical_conditions"
        case medication
    }
}

// MARK: - Constants
enum Gender: String, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
    case preferNotToSay = "Prefer not to say"
}

struct MedicalCondition: Identifiable, Hashable, Equatable {
    let id = UUID()
    let name: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MedicalCondition, rhs: MedicalCondition) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Medication: Identifiable {
    let id = UUID()
    let name: String
    let description: String
}

// MARK: - ViewModel
import SwiftUI
import Combine

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedConditions = Set<MedicalCondition>()
    @Published var selectedMedication: Medication?
    @Published var selectedGender: Gender?
    @Published var selectedDate = Date()
    @Published var selectedHeight: Int = 170
    
    static let medicalConditions = [
        MedicalCondition(name: "Hypertension"),
        MedicalCondition(name: "Diabetes Type 2"),
        MedicalCondition(name: "High Cholesterol"),
        MedicalCondition(name: "Heart Disease"),
        MedicalCondition(name: "Obesity"),
        MedicalCondition(name: "Sleep Apnea"),
        MedicalCondition(name: "Thyroid Issues")
    ]
    
    static let medications = [
        Medication(name: "Metformin", description: "For diabetes and weight management"),
        Medication(name: "GLP-1 Agonists", description: "For weight loss and diabetes"),
        Medication(name: "Orlistat", description: "For weight loss"),
        Medication(name: "Phentermine", description: "For short-term weight management"),
        Medication(name: "Bupropion-Naltrexone", description: "For weight loss"),
        Medication(name: "Liraglutide", description: "For chronic weight management"),
        Medication(name: "Blood Pressure Medication", description: "For blood pressure management"),

    ]
    
    func fetchUserProfile(userId: Int) async {
        print("Fetching profile for userId: \(userId)")
        isLoading = true
        error = nil
        
        do {
            let response = try await APIService.getUserProfile(userId: userId)
            await MainActor.run {
                userProfile = response.data
                print("Profile fetched successfully: \(String(describing: userProfile))")
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                print("Error fetching user profile: \(error)")
                isLoading = false
            }
        }
    }
    
    func formattedDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let date = dateFormatter.date(from: dateString) else { return dateString }
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    func formattedDateFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    func getWeightProgress() -> Double {
        guard let profile = userProfile else { return 0.0 }
        let totalChange = Double(profile.detail.startWeight - profile.detail.targetWeight)
        let currentChange = Double(profile.detail.startWeight - profile.detail.weight)
        guard totalChange != 0 else { return 0.0 }
        return (currentChange / totalChange) * 100.0
    }
}

// MARK: - Views
struct UserProfileView: View {
    @EnvironmentObject var viewModel: UserProfileViewModel
    
    var body: some View {
        ScrollView {
            if let profile = viewModel.userProfile {
                VStack(spacing: 20) {
                    UserInfoCard(profile: profile)
                    HealthGoalsCard(profile: profile, viewModel: viewModel)
                    WeightProgressCard(profile: profile, viewModel: viewModel)
                    DetailInfoCard(profile: profile, viewModel: viewModel)
                }
                .padding()
            } else if viewModel.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.error != nil {
                Text("Failed to load. Tap to retry")
                    .foregroundColor(AppTheme.error)
            }
        }
        .navigationTitle("Profile")
        .background(AppTheme.background)
    }
}

struct UserInfoCard: View {
    let profile: UserProfile
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(AppTheme.primary)
            
            Text(profile.username)
                .font(.title2)
                .bold()
                .foregroundColor(AppTheme.textPrimary)
            
            Text(profile.email)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppTheme.secondaryBackground)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct HealthGoalsCard: View {
    let profile: UserProfile
    @ObservedObject var viewModel: UserProfileViewModel
    @State private var showingTargetWeightPicker = false
    @State private var showingTargetDatePicker = false
    @State private var targetWeight: Int
    @State private var targetDate: Date
    
    init(profile: UserProfile, viewModel: UserProfileViewModel) {
        self.profile = profile
        self.viewModel = viewModel
        _targetWeight = State(initialValue: profile.detail.targetWeight)
        _targetDate = State(initialValue: {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            return formatter.date(from: profile.detail.targetDate) ?? Date()
        }())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Health Goals")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: 8) {
                Button(action: { showingTargetWeightPicker = true }) {
                    InfoRow(title: "Target Weight", value: "\(targetWeight) kg")
                }
                Button(action: { showingTargetDatePicker = true }) {
                    InfoRow(title: "Target Date", value: viewModel.formattedDate(profile.detail.targetDate))
                }
                InfoRow(title: "Start Date", value: viewModel.formattedDate(profile.detail.startDate))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.secondaryBackground)
        .cornerRadius(12)
        .shadow(radius: 2)
        .sheet(isPresented: $showingTargetWeightPicker) {
            NavigationView {
                Form {
                    Picker("Target Weight", selection: $targetWeight) {
                        ForEach(30...200, id: \.self) { weight in
                            Text("\(weight) kg").tag(weight)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .navigationTitle("Select Target Weight")
                .navigationBarItems(trailing: Button("Done") {
                    showingTargetWeightPicker = false
                })
            }
        }
        .sheet(isPresented: $showingTargetDatePicker) {
            NavigationView {
                DatePicker("Select Target Date", selection: $targetDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                    .navigationTitle("Target Date")
                    .navigationBarItems(trailing: Button("Done") {
                        showingTargetDatePicker = false
                    })
            }
        }
    }
}

struct WeightProgressCard: View {
    let profile: UserProfile
    @ObservedObject var viewModel: UserProfileViewModel
    @State private var showingWeightPicker = false
    @State private var currentWeight: Int
    
    init(profile: UserProfile, viewModel: UserProfileViewModel) {
        self.profile = profile
        self.viewModel = viewModel
        _currentWeight = State(initialValue: profile.detail.weight)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weight Progress")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: 8) {
                Button(action: { showingWeightPicker = true }) {
                    InfoRow(title: "Current Weight", value: "\(currentWeight) kg")
                }
                InfoRow(title: "Start Weight", value: "\(profile.detail.startWeight) kg")
                InfoRow(title: "Target Weight", value: "\(profile.detail.targetWeight) kg")
                
                ProgressView(value: viewModel.getWeightProgress(), total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: AppTheme.primary))
                    .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.secondaryBackground)
        .cornerRadius(12)
        .shadow(radius: 2)
        .sheet(isPresented: $showingWeightPicker) {
            NavigationView {
                Form {
                    Picker("Current Weight", selection: $currentWeight) {
                        ForEach(30...200, id: \.self) { weight in
                            Text("\(weight) kg").tag(weight)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .navigationTitle("Select Current Weight")
                .navigationBarItems(trailing: Button("Done") {
                    showingWeightPicker = false
                })
            }
        }
    }
}

struct DetailInfoCard: View {
    let profile: UserProfile
    @ObservedObject var viewModel: UserProfileViewModel
    @State private var showingGenderPicker = false
    @State private var showingDatePicker = false
    @State private var showingHeightPicker = false
    @State private var showingMedicalConditionsPicker = false
    @State private var showingMedicationPicker = false
    @State private var selectedBirthday: Date
    @State private var selectedHeight: Int
    @State private var selectedGender: String
    @State private var selectedMedicalConditions: Set<MedicalCondition>
    @State private var selectedMedication: Medication?
    
    init(profile: UserProfile, viewModel: UserProfileViewModel) {
        self.profile = profile
        self.viewModel = viewModel
        
        // 初始化生日
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let birthdayDate = dateFormatter.date(from: profile.detail.birthday) ?? Date()
        _selectedBirthday = State(initialValue: birthdayDate)
        
        // 初始化身高
        _selectedHeight = State(initialValue: profile.detail.height)
        
        // 初始化性别
        _selectedGender = State(initialValue: profile.detail.gender ?? "Not specified")
        
        // 初始化医疗条件
        print("Medical conditions from backend: \(profile.detail.medicalConditions)")
        let initialConditions = Set(UserProfileViewModel.medicalConditions.filter { condition in
            profile.detail.medicalConditions.contains(condition.name)
        })
        print("Initialized medical conditions: \(initialConditions.map { $0.name })")
        _selectedMedicalConditions = State(initialValue: initialConditions)
        
        // 初始化药物
        let medicationJson = profile.detail.medication ?? "[]"
        print("Raw medication data: \(medicationJson)")
        
        if let medicationData = medicationJson.data(using: .utf8) {
            do {
                let medications = try JSONDecoder().decode([String].self, from: medicationData)
                print("Decoded medications: \(medications)")
                
                if !medications.isEmpty {
                    if let matchedMedication = UserProfileViewModel.medications.first(where: { medications.contains($0.name) }) {
                        print("Found matching medication: \(matchedMedication.name)")
                        _selectedMedication = State(initialValue: matchedMedication)
                    } else {
                        print("No matching medication found in predefined list")
                        _selectedMedication = State(initialValue: nil)
                    }
                } else {
                    print("Medications array is empty")
                    _selectedMedication = State(initialValue: nil)
                }
            } catch {
                print("Error decoding medications: \(error)")
                _selectedMedication = State(initialValue: nil)
            }
        } else {
            print("Could not convert medication JSON to data")
            _selectedMedication = State(initialValue: nil)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personal Details")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: 8) {
                // Gender
                Button(action: { showingGenderPicker = true }) {
                    InfoRow(title: "Gender", value: selectedGender)
                }
                .sheet(isPresented: $showingGenderPicker) {
                    NavigationView {
                        List(Gender.allCases, id: \.self) { gender in
                            Button(action: {
                                selectedGender = gender.rawValue
                                showingGenderPicker = false
                            }) {
                                Text(gender.rawValue)
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                        }
                        .navigationTitle("Select Gender")
                        .navigationBarItems(trailing: Button("Done") {
                            showingGenderPicker = false
                        })
                    }
                }
                
                // Birthday
                Button(action: { showingDatePicker = true }) {
                    InfoRow(title: "Birthday", value: viewModel.formattedDateFromDate(selectedBirthday))
                }
                .sheet(isPresented: $showingDatePicker) {
                    NavigationView {
                        DatePicker("Select Birthday", selection: $selectedBirthday, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .padding()
                            .navigationTitle("Birthday")
                            .navigationBarItems(trailing: Button("Done") {
                                showingDatePicker = false
                            })
                    }
                }
                
                // Height
                Button(action: { showingHeightPicker = true }) {
                    InfoRow(title: "Height", value: "\(selectedHeight) cm")
                }
                .sheet(isPresented: $showingHeightPicker) {
                    NavigationView {
                        Form {
                            Picker("Height", selection: $selectedHeight) {
                                ForEach(100...250, id: \.self) { height in
                                    Text("\(height) cm").tag(height)
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                        .navigationTitle("Select Height")
                        .navigationBarItems(trailing: Button("Done") {
                            showingHeightPicker = false
                        })
                    }
                }
                
                // Medical Conditions
                Button(action: { showingMedicalConditionsPicker = true }) {
                    InfoRow(title: "Medical Conditions", 
                           value: selectedMedicalConditions.isEmpty ? "None" : 
                                 selectedMedicalConditions.map { $0.name }.joined(separator: ", "))
                }
                .sheet(isPresented: $showingMedicalConditionsPicker) {
                    NavigationView {
                        List {
                            ForEach(UserProfileViewModel.medicalConditions) { condition in
                                Toggle(condition.name, isOn: Binding(
                                    get: { selectedMedicalConditions.contains(condition) },
                                    set: { isSelected in
                                        if isSelected {
                                            selectedMedicalConditions.insert(condition)
                                        } else {
                                            selectedMedicalConditions.remove(condition)
                                        }
                                    }
                                ))
                            }
                        }
                        .navigationTitle("Medical Conditions")
                        .navigationBarItems(trailing: Button("Done") {
                            showingMedicalConditionsPicker = false
                        })
                    }
                }
                
                // Medications
                Button(action: { showingMedicationPicker = true }) {
                    InfoRow(title: "Medication", 
                           value: selectedMedication?.name ?? "None")
                }
                .sheet(isPresented: $showingMedicationPicker) {
                    NavigationView {
                        List(UserProfileViewModel.medications) { medication in
                            Button(action: {
                                selectedMedication = medication
                                showingMedicationPicker = false
                            }) {
                                VStack(alignment: .leading) {
                                    Text(medication.name)
                                        .foregroundColor(selectedMedication?.id == medication.id ? .blue : .primary)
                                    if !medication.description.isEmpty {
                                        Text(medication.description)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .navigationTitle("Select Medication")
                        .navigationBarItems(trailing: Button("Done") {
                            showingMedicationPicker = false
                        })
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.secondaryBackground)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .foregroundColor(AppTheme.textPrimary)
        }
    }
}
