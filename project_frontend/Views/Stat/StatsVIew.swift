import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var healthManager = HealthManager()
    @State private var weightRecords: [WeightRecord] = []
    @State private var mergedWeightData: [(date: Date, weight: Double)] = []
    @State private var caloriesData: [(date: Date, calories: Double)] = []
    @State private var exerciseData: [(date: Date, minutes: Double)] = []
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var caloriesGoal = 400.0
    
    let nutritionData = [
        ("Protein", 30.0, AppTheme.primary),
        ("Carbs", 40.0, AppTheme.success),
        ("Fat", 30.0, AppTheme.warning)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    DraggableCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Weight Trend")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else if weightRecords.isEmpty {
                                Text("No weight records available")
                                    .foregroundColor(AppTheme.textSecondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else {
                                // Weight Chart
                                Chart {
                                    ForEach(Array(mergedWeightData.enumerated()), id: \.offset) { _, data in
                                        LineMark(
                                            x: .value("Date", data.date),
                                            y: .value("Weight", data.weight)
                                        )
                                        .foregroundStyle(AppTheme.primary)
                                        
                                        PointMark(
                                            x: .value("Date", data.date),
                                            y: .value("Weight", data.weight)
                                        )
                                        .foregroundStyle(AppTheme.primary)
                                    }
                                }
                                .frame(height: 160)
                                .padding(.vertical)
                            }
                        }
                        .padding()
                        .background(AppTheme.secondaryBackground)
                        .cornerRadius(12)
                    }
                    
                    DraggableCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Calories Trend")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else if caloriesData.isEmpty {
                                Text("No calories data available")
                                    .foregroundColor(AppTheme.textSecondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else {
                                VStack(alignment: .center, spacing: 20) {
                                    ZStack {
                                        Circle()
                                            .stroke(AppTheme.secondaryBackground, lineWidth: 20)
                                            .frame(width: 120, height: 120)
                                        
                                        Circle()
                                            .trim(from: 0, to: CGFloat(min(caloriesData.last?.calories ?? 0, caloriesGoal) / caloriesGoal))
                                            .stroke(AppTheme.warning, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                            .frame(width: 120, height: 120)
                                            .rotationEffect(.degrees(-90))
                                        
                                        VStack {
                                            Text("\(Int(caloriesData.last?.calories ?? 0))")
                                                .font(.system(size: 30, weight: .bold))
                                                .foregroundColor(AppTheme.textPrimary)
                                            Text("calories")
                                                .font(.subheadline)
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                    }
                                    

                                }
                                .frame(height: 160)
                                .padding(.vertical)
                                .onTapGesture {
                                    // 添加点击交互，可以在这里处理点击事件
                                    print("Exercise card tapped")
                                }
                            }
                        }
                        .padding()
                        .background(AppTheme.secondaryBackground)
                        .cornerRadius(12)
                    }
                    
                    DraggableCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Exercise Time")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else if exerciseData.isEmpty {
                                Text("No exercise data available")
                                    .foregroundColor(AppTheme.textSecondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else {
                                VStack(alignment: .center, spacing: 20) {
                                    let todayExercise = exerciseData.last?.minutes ?? 0
                                    Text(String(format: "%.0f", todayExercise))
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Text("mins")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    Chart {
                                        ForEach(exerciseData, id: \.date) { data in
                                            BarMark(
                                                x: .value("Date", {
                                                    let weekday = Calendar.current.component(.weekday, from: data.date)
                                                    switch weekday {
                                                    case 1: return "Sun"
                                                    case 2: return "Mon"
                                                    case 3: return "Tue"
                                                    case 4: return "Wed"
                                                    case 5: return "Thu"
                                                    case 6: return "Fri"
                                                    case 7: return "Sat"
                                                    default: return ""
                                                    }
                                                }()),
                                                y: .value("Minutes", data.minutes)
                                            )
                                            .foregroundStyle(AppTheme.primary)
                                        }
                                    }
                                    .frame(height: 120)
                                    .padding(.top)
                                }
                                .frame(height: 200)
                                .padding(.vertical)
                                .onTapGesture {
                                    // 添加点击交互，可以在这里处理点击事件
                                    print("Exercise card tapped")
                                }
                            }
                        }
                        .padding()
                        .background(AppTheme.secondaryBackground)
                        .cornerRadius(12)
                    }
                    
                    DraggableCard {
                        NutritionCard(nutritionData: nutritionData)
                    }
                }
                .padding()
            }
            .navigationTitle("Statistics")
            .onAppear {
                fetchWeightTrend()
                fetchCaloriesData()
                fetchExerciseData()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func fetchCaloriesData() {
        Task {
            do {
                let authSuccess = await withCheckedContinuation { continuation in
                    healthManager.requestAuthorization { success in
                        continuation.resume(returning: success)
                    }
                }
                
                if !authSuccess {
                    await MainActor.run {
                        errorMessage = "无法访问健康数据，请在设置中授予权限"
                        showError = true
                    }
                    return
                }
                
                let data = await withCheckedContinuation { continuation in
                    healthManager.fetchCaloriesData { data in
                        continuation.resume(returning: data)
                    }
                }
                
                await MainActor.run {
                    caloriesData = data
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func fetchExerciseData() {
        Task {
            do {
                let authSuccess = await withCheckedContinuation { continuation in
                    healthManager.requestAuthorization { success in
                        continuation.resume(returning: success)
                    }
                }
                
                if !authSuccess {
                    await MainActor.run {
                        errorMessage = "无法访问健康数据，请在设置中授予权限"
                        showError = true
                    }
                    return
                }
                
                let data = await withCheckedContinuation { continuation in
                    healthManager.fetchExerciseData { data in
                        continuation.resume(returning: data)
                    }
                }
                
                await MainActor.run {
                    exerciseData = data
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func fetchWeightTrend() {
        guard let userId = authViewModel.userId else {
            errorMessage = "User ID not found"
            showError = true
            return
        }
        
        isLoading = true
        
        // 请求HealthKit权限
        Task {
            do {
                let authSuccess = await withCheckedContinuation { continuation in
                    healthManager.requestAuthorization { success in
                        continuation.resume(returning: success)
                    }
                }
                
                if !authSuccess {
                    await MainActor.run {
                        errorMessage = "无法访问健康数据，请在设置中授予权限"
                        showError = true
                        isLoading = false
                    }
                    return
                }
                
                // 获取HealthKit数据
                let healthKitData = await withCheckedContinuation { continuation in
                    healthManager.fetchWeightData { data in
                        continuation.resume(returning: data)
                    }
                }
                
                // 获取后台数据
                let response = try await APIService.getWeightTrend(userId: userId)
                
                await MainActor.run {
                    weightRecords = response.data
                    // 合并数据
                    mergedWeightData = healthManager.mergeWeightData(healthKitData: healthKitData, backendData: response.data)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isLoading = false
                }
            }
        }
    }
    
    private func dateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}

struct DraggableCard<Content: View>: View {
    let content: Content
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var isExpanded = false
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastScale
                            lastScale = value
                            scale = min(max(scale * delta, 0.5), 2.0)
                        }
                        .onEnded { _ in
                            lastScale = 1.0
                        },
                    DragGesture()
                        .onChanged { value in
                            let delta = CGSize(
                                width: value.translation.width - lastOffset.width,
                                height: value.translation.height - lastOffset.height
                            )
                            lastOffset = value.translation
                            offset = CGSize(
                                width: offset.width + delta.width,
                                height: offset.height + delta.height
                            )
                        }
                        .onEnded { _ in
                            lastOffset = .zero
                        }
                )
            )
            .animation(.interactiveSpring(), value: scale)
            .animation(.interactiveSpring(), value: offset)
    }
}

// MARK: - Weight Trend Card
struct WeightTrendCard: View {
    let weightData: [(date: Date, weight: Double)]
    let targetWeight: Double
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var isExpanded = false
    
    var currentWeight: Double {
        weightData.last?.weight ?? 0
    }
    
    var weightDifference: Double {
        currentWeight - targetWeight
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Weight Trend")
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(String(format: "%.1f", currentWeight)) kg")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    Text("\(weightDifference > 0 ? "+" : "")\(String(format: "%.1f", weightDifference)) kg")
                        .font(.subheadline)
                        .foregroundColor(weightDifference > 0 ? AppTheme.error : AppTheme.success)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(weightDifference > 0 ? AppTheme.error.opacity(0.1) : AppTheme.success.opacity(0.1))
                        )
                }
                
                Text("Target: \(String(format: "%.1f", targetWeight)) kg")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            ZoomableChart(weightData: weightData, targetWeight: targetWeight, isExpanded: isExpanded)
        }
        .padding()
        .background(AppTheme.secondaryBackground)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ZoomableChart: View {
    let weightData: [(date: Date, weight: Double)]
    let targetWeight: Double
    let isExpanded: Bool
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        Chart {
            ForEach(weightData, id: \.date) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Weight", item.weight)
                )
                .foregroundStyle(AppTheme.primary)
                
                PointMark(
                    x: .value("Date", item.date),
                    y: .value("Weight", item.weight)
                )
                .foregroundStyle(AppTheme.primary)
            }
            
            RuleMark(
                y: .value("Target", targetWeight)
            )
            .foregroundStyle(AppTheme.success.opacity(0.5))
            .lineStyle(StrokeStyle(dash: [5, 5]))
        }
        .frame(height: isExpanded ? 300 : 120)
        .scaleEffect(scale)
        .offset(offset)
        .gesture(
            SimultaneousGesture(
                MagnificationGesture()
                    .onChanged { value in
                        let delta = value / lastScale
                        lastScale = value
                        scale = min(max(scale * delta, 1), 3)
                    }
                    .onEnded { _ in
                        lastScale = 1.0
                    },
                DragGesture()
                    .onChanged { value in
                        let delta = CGSize(
                            width: value.translation.width - lastOffset.width,
                            height: value.translation.height - lastOffset.height
                        )
                        lastOffset = value.translation
                        offset = CGSize(
                            width: offset.width + delta.width,
                            height: offset.height + delta.height
                        )
                    }
                    .onEnded { _ in
                        lastOffset = .zero
                    }
            )
        )
        .animation(.interactiveSpring(), value: isExpanded)
        .clipped()
    }
}

// MARK: - Calories Card
struct CaloriesCard: View {
    let goal: Double
    let current: Double
    
    var progress: Double {
        min(current / goal, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Calories")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            ZStack {
                Circle()
                    .stroke(AppTheme.secondaryBackground, lineWidth: 10)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(AppTheme.primary, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(Int(current))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    Text("/ \(Int(goal))")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(.vertical, 10)
        }
        .padding()
        .background(AppTheme.secondaryBackground)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Exercise Card
struct ExerciseCard: View {
    let exerciseData: [(String, Int)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Exercise Duration")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            Chart {
                ForEach(exerciseData, id: \.0) { item in
                    BarMark(
                        x: .value("Day", item.0),
                        y: .value("Minutes", item.1)
                    )
                    .foregroundStyle(AppTheme.success)
                }
            }
            .frame(height: 150)
        }
        .padding()
        .background(AppTheme.secondaryBackground)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Nutrition Card
struct NutritionCard: View {
    let nutritionData: [(String, Double, Color)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nutrition Distribution")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            ForEach(nutritionData, id: \.0) { item in
                HStack {
                    Text(item.0)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Spacer()
                    
                    Text("\(Int(item.1))%")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(AppTheme.secondaryBackground)
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(item.2)
                            .frame(width: geometry.size.width * item.1 / 100, height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(AppTheme.secondaryBackground)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
            .environmentObject(AuthViewModel())
    }
}
