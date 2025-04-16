import SwiftUI

struct RecommendFoodView: View {
    @State private var showingPersonalizationSheet = false
    @State private var dietaryPreference = "nothing"
    @State private var showHealthTips = false
    @State private var recommendData: RecommendData?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var lastUpdateDate: Date?
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private var shouldRefreshData: Bool {
        guard let lastUpdate = lastUpdateDate else { return true }
        return !Calendar.current.isDate(lastUpdate, inSameDayAs: Date())    
    }
    
    private var nutritionalBalance: NutritionalBalance {
        recommendData?.nutritional_balance ?? NutritionalBalance(carbohydrates_percentage: 0, fat_percentage: 0, protein_percentage: 0)
    }
    
    private var healthTips: [String] {
        recommendData?.health_tips ?? []
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Personalization Button
                    Button(action: {
                        print("[RecommendFood] 点击个性化设置按钮")
                        showingPersonalizationSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Personalize")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    if let data = recommendData {
                        VStack(spacing: 16) {
                            let sortedMeals = data.recommended_meals.sorted { meal1, meal2 in
                                let mealOrder = ["Breakfast": 1, "Lunch": 2, "Dinner": 3]
                                return (mealOrder[meal1.meal_type] ?? 0) < (mealOrder[meal2.meal_type] ?? 0)
                            }
                            ForEach(sortedMeals, id: \.meal_type) { meal in
                                VStack {
                                    mealSection(title: meal.meal_type, foods: meal.foods)
                                }
                                .padding(.horizontal)
                            }
                        }
                    } else if isLoading {
                        VStack(spacing: 8) {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                            Text("Processing...")
                                .foregroundColor(AppTheme.textSecondary)
                                .font(.subheadline)
                        }
                    }
                    
                    // Health Tips
                    VStack {
                        healthTipsView
                    }
                    .padding(.horizontal)

                    // Nutritional Balance
                    VStack {
                        nutritionBalanceView
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Today's Menu 🍜")
            .sheet(isPresented: $showingPersonalizationSheet) {
                PersonalizationSheet(dietaryPreference: $dietaryPreference)
            }
            .onAppear {
                if shouldRefreshData {
                    Task {
                        await loadRecommendedFood()
                        lastUpdateDate = Date()
                    }
                }
                
                // 添加通知监听，仅用于个性化设置更新
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name("RefreshRecommendedFood"),
                    object: nil,
                    queue: .main
                ) { _ in
                    Task {
                        await loadRecommendedFood()
                        lastUpdateDate = Date()
                    }
                }
            }
        }
    }
    
    private func loadRecommendedFood() async {
        print("[RecommendFood] 开始加载推荐食物数据")
        guard let userId = authViewModel.userId else {
            print("[RecommendFood] 错误：用户未登录")
            errorMessage = "Please login first"
            return
        }
        
        print("[RecommendFood] 用户ID: \(userId), 饮食偏好: \(dietaryPreference)")
        isLoading = true
        do {
            print("[RecommendFood] 正在调用API获取推荐食物...")
            let response = try await APIService.getRecommendedFood(userId: userId, personalized: dietaryPreference)
            print("[RecommendFood] API调用成功，获取到响应数据")
            await MainActor.run {
                print("[RecommendFood] 更新UI数据：\(response.data)")
                recommendData = response.data
                isLoading = false
            }
        } catch {
            print("[RecommendFood] API调用失败：\(error.localizedDescription)")
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    private func updatePreferences() async {
        print("[RecommendFood] 开始更新饮食偏好设置")
        guard let userId = authViewModel.userId else {
            print("[RecommendFood] 错误：用户未登录")
            errorMessage = "Please login first"
            showError = true
            return
        }
        
        print("[RecommendFood] 用户ID: \(userId), 新的饮食偏好: \(dietaryPreference)")
        isLoading = true
        do {
            let response = try await APIService.getRecommendedFood(userId: userId, personalized: dietaryPreference)
            print("[RecommendFood] API调用成功，获取到响应数据")
            
            if response.code == 200 {
                print("[RecommendFood] 更新成功，关闭设置页面")
                // 通知父组件重新加载数据
                Task {
                    await loadRecommendedFood()
                }
            } else {
                print("[RecommendFood] 更新失败：\(response.message)")
                errorMessage = response.message
                showError = true
            }
        } catch {
            print("[RecommendFood] 更新过程发生错误：\(error.localizedDescription)")
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    private func mealSection(title: String, foods: [RecommendedFood]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            ForEach(foods, id: \.food_name) { food in
                foodCard(food: FoodItem(from: food))
            }
        }
        .padding()
        .background(AppTheme.secondaryBackground)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func foodCard(food: FoodItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    if let portionSize = food.portionSize {
                        Text(portionSize)
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%.2f Calories", food.calories))
                        .font(.subheadline)
                        .foregroundColor(AppTheme.primary)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < food.rating ? "star.fill" : "star")
                                .foregroundColor(index < food.rating ? .yellow : .gray)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    private var nutritionBalanceView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nutritional Balance")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: 16) {
                NutritionBar(title: "Carbohydrates", percentage: nutritionalBalance.carbohydrates, color: AppTheme.success)
                NutritionBar(title: "Protein", percentage: nutritionalBalance.protein, color: AppTheme.primary)
                NutritionBar(title: "Fat", percentage: nutritionalBalance.fat, color: AppTheme.warning)
            }
        }
        .padding()
        .background(AppTheme.secondaryBackground)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var healthTipsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Health Tips")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            ForEach(healthTips, id: \.self) { tip in
                Text(tip)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary.opacity(0.8))
                    .lineSpacing(4)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                    )
            }
        }
        .padding(20)
        .background(AppTheme.secondaryBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}

// 个性化设置表单
struct PersonalizationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var dietaryPreference: String
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Dietary Preferences")) {
                    TextField("Enter your dietary preferences", text: $dietaryPreference)
                        .foregroundColor(dietaryPreference.isEmpty ? .gray : .primary)
                }
            }
            .navigationTitle("Personalization")
            .navigationBarItems(trailing: Button("Done") {
                Task {
                    isLoading = true
                    await updatePreferences()
                    isLoading = false
                }
            })
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .overlay {
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    Text("Processing...")
                        .foregroundColor(AppTheme.textSecondary)
                        .font(.subheadline)
                }
            }
        }
    }
    
    private func updatePreferences() async {
        print("[RecommendFood] 开始更新饮食偏好设置")
        guard let userId = authViewModel.userId else {
            print("[RecommendFood] 错误：用户未登录")
            errorMessage = "Please login first"
            showError = true
            return
        }
        
        print("[RecommendFood] 用户ID: \(userId), 新的饮食偏好: \(dietaryPreference)")
        isLoading = true
        do {
            let response = try await APIService.getRecommendedFood(userId: userId, personalized: dietaryPreference)
            print("[RecommendFood] API调用成功，获取到响应数据")
            
            if response.code == 200 {
                print("[RecommendFood] 更新成功，关闭设置页面")
                // 通知父组件重新加载数据
                NotificationCenter.default.post(name: NSNotification.Name("RefreshRecommendedFood"), object: nil)
                // 确保在数据更新成功后再关闭页面
                dismiss()
            } else {
                print("[RecommendFood] 更新失败：\(response.message)")
                errorMessage = response.message
                showError = true
            }
        } catch {
            print("[RecommendFood] 更新过程发生错误：\(error.localizedDescription)")
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// 数据模型
// API响应模型
struct RecommendResponse: Codable {
    let code: Int
    let message: String
    let data: RecommendData
}

struct RecommendData: Codable {
    let dietary_restrictions: [String]
    let health_tips: [String]
    let nutritional_balance: NutritionalBalance
    let recommended_meals: [RecommendedMeal]
    let total_calories: Int
}

struct NutritionalBalance: Codable {
    let carbohydrates_percentage: Double
    let fat_percentage: Double
    let protein_percentage: Double
    
    var carbohydrates: Double { carbohydrates_percentage }
    var fat: Double { fat_percentage }
    var protein: Double { protein_percentage }
}

struct RecommendedMeal: Codable {
    let foods: [RecommendedFood]
    let meal_type: String
}

struct RecommendedFood: Codable {
    let food_name: String
    let portion_size: String
    let rate: Int?
    let foodcalories: Float
}

struct FoodItem: Codable {
    let name: String
    let portionSize: String?
    let calories: Float
    let rating: Int
    
    init(from recommendedFood: RecommendedFood) {
        self.name = recommendedFood.food_name
        self.portionSize = recommendedFood.portion_size
        self.calories = recommendedFood.foodcalories ?? 0  // 添加默认值0
        self.rating = recommendedFood.rate ?? 0  // 已有默认值处理
    }
}

struct NutritionBar: View {
    let title: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text(String(format: "%.0f%%", percentage))
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(percentage / 100), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

struct RecommendFoodView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendFoodView()
            .environmentObject(AuthViewModel())
    }
}
