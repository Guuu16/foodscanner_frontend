import SwiftUI
import Foundation

struct DiaryView: View {
    @State private var selectedDate = Date()
    @State private var selectedOffset = 0
    @State private var showingProfile = false
    @State private var foodRecords: [FoodRecord] = []
    @State private var isLoading = false
    @AppStorage("user_id") private var userId: Int = 0
    
    // 添加缓存字典来存储不同日期的食物记录
    @State private var cachedRecords: [String: [FoodRecord]] = [:]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // 顶部标题区域
                    VStack(alignment: .leading, spacing: 8) {
                        Text("RECORDING📝")
                            .font(.title)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(selectedDate.formatted(date: .long, time: .omitted))
                            .font(.body)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    // 日期选择器
                    ScrollView(.horizontal, showsIndicators: false) {
                        ScrollViewReader { proxy in
                            HStack(spacing: 8) {
                                ForEach(-30...0, id: \.self) { offset in
                                    DateCell(
                                        date: Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date(),
                                        isSelected: offset == selectedOffset
                                    )
                                    .id(offset)
                                    .onTapGesture {
                                        withAnimation {
                                            selectedOffset = offset
                                            selectedDate = Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()
                                        }
                                    }
                                    .simultaneousGesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { _ in
                                                withAnimation {
                                                    if offset != selectedOffset {
                                                        proxy.scrollTo(offset)
                                                    }
                                                }
                                            }
                                            .onEnded { _ in
                                                withAnimation {
                                                    selectedOffset = offset
                                                    selectedDate = Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()
                                                }
                                            }
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            .onAppear {
                                withAnimation {
                                    proxy.scrollTo(0, anchor: .trailing)
                                }
                            }
                        }
                    }
                    
                                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if foodRecords.isEmpty {
                        VStack(spacing: 16) {
                            Text("No pains, no gains!")
                                .font(.title)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("Let's log the first item of the day!")
                                .font(.body)
                                .foregroundColor(AppTheme.textSecondary)
                                
                            Image(systemName: "fork.knife.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .foregroundColor(AppTheme.primary)
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(foodRecords) { record in
                                    let deleteAction = {
                                        Task {
                                            await handleDeleteRecord(record)
                                        }
                                        // 返回Void以匹配() -> Void类型
                                        ()
                                    }
                                    
                                    FoodRecordCard(record: record, onDelete: deleteAction)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // 添加按钮
                    Button(action: {
                        // 添加食物项目的操作
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                            VStack(alignment: .leading) {
                                Text("Add Item")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("for the selected day")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(AppTheme.secondaryBackground)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 24)
                    
                    // 底部标签栏
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(action: {
                    showingProfile.toggle()
                }) {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(AppTheme.primary)
                }
            )
            .sheet(isPresented: $showingProfile) {
                UserProfileView()
            }
            .onChange(of: selectedDate) { _ in
                foodRecords = []  // 清空现有记录
                Task {
                    await loadFoodRecords()
                }
            }
            .onAppear {
                Task {
                    await loadFoodRecords()
                }
            }
        }
    }
    
    private func loadFoodRecords() async {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: selectedDate)
        
        // 检查缓存中是否有数据
        if let cachedData = cachedRecords[dateString] {
            foodRecords = cachedData
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await APIService.getFoodRecords(userId: String(userId), date: dateString)
            await MainActor.run {
                foodRecords = response.data
                // 将数据存入缓存
                cachedRecords[dateString] = response.data
            }
        } catch {
            print("Error loading food records: \(error)")
        }
    }
    
    @State private var deletingRecordId: Int? = nil
    private func handleDeleteRecord(_ record: FoodRecord) async {
        withAnimation(.easeInOut(duration: 0.3)) {
            deletingRecordId = record.id
        }
        
        // 延迟执行删除操作，让动画有时间完成
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        do {
            // 调用API删除记录
            let response = try await APIService.deleteRecord(recordId: record.id)
            
            if response.code == 200 {
                // 清除缓存，强制下次重新加载
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateString = dateFormatter.string(from: selectedDate)
                cachedRecords.removeValue(forKey: dateString)
                
                // 从当前记录列表中移除被删除的记录
                await MainActor.run {
                    foodRecords.removeAll { $0.id == response.data.deleted_id }
                }
            }
        } catch {
            print("Error deleting record: \(error)")
        }
    }
}

struct FoodRecordCard: View {
    let record: FoodRecord
    @State private var showingDetail = false
    var onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                showingDetail = true
            }) {
                VStack(alignment: .leading, spacing: 12) {
                    AsyncImage(url: URL(string: APIService.bURL + record.file_path)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .clipped()
                        case .failure(_):
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.width - 48)
                                .frame(height: 200)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(record.description.food_name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        HStack(spacing: 16) {
                            NutritionLabel(title: "Calories", value: "\(record.description.calories)")
                            NutritionLabel(title: "Protein", value: "\(record.description.protein)g")
                            NutritionLabel(title: "Fat", value: "\(record.description.fat)g")
                            NutritionLabel(title: "Carbs", value: "\(record.description.carbohydrates)g")
                        }
                    }
                    .padding(12)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .background(AppTheme.secondaryBackground)
        .cornerRadius(16)
        .shadow(radius: 2)
        .sheet(isPresented: $showingDetail) {
            FoodDetailView(record: record, onDelete: onDelete)
        }
    }
}

struct FoodDetailView: View {
    let record: FoodRecord
    @Environment(\.dismiss) private var dismiss
    var onDelete: () -> Void
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack {
            // 背景颜色
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            // 内容
            ScrollView {
                VStack(spacing: 24) {
                    // 食物图片
                    AsyncImage(url: URL(string: APIService.bURL + record.file_path)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 300)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 5)
                                .overlay(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                        case .failure(_):
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 300)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .padding(.top, 20)
                    
                    // 食物信息
                    VStack(alignment: .leading, spacing: 20) {
                        Text(record.description.food_name)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        
                        // 营养信息卡片
                        VStack(spacing: 16) {
                            NutritionDetailRow(title: "Calories", value: "\(record.description.calories) kcal")
                            NutritionDetailRow(title: "Protein", value: "\(record.description.protein)g")
                            NutritionDetailRow(title: "Fat", value: "\(record.description.fat)g")
                            NutritionDetailRow(title: "Carbohydrates", value: "\(record.description.carbohydrates)g")
                        }
                        .padding(24)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
                
                // 删除按钮
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Delete Record")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .alert("Delete Record", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    onDelete()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this record? This action cannot be undone.")
            }
            
            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

struct NutritionDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
    }
}

struct NutritionLabel: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textPrimary)
        }
    }
        }


struct DateCell: View {
    let date: Date
    let isSelected: Bool
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 4) {
            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                .font(.caption)
                .fontWeight(.medium)
            Text(date.formatted(.dateTime.day()))
                .font(.title3)
                .fontWeight(.semibold)
            Circle()
                .fill(isSelected ? AppTheme.background : AppTheme.textSecondary)
                .frame(width: 3, height: 3)
        }
        .frame(width: 45, height: 65)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? AppTheme.primary : AppTheme.secondaryBackground)
        )
        .foregroundColor(isSelected ? AppTheme.background : AppTheme.textPrimary)
        .scaleEffect(isSelected ? 1.2 : (isPressed ? 0.95 : 1.0))
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
    }
}

struct TabBarButton: View {
    let icon: String
    let text: String
    var isSelected: Bool = false
    var isAccent: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
            Text(text)
                .font(.caption2)
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(
            isAccent ? AppTheme.primary :
            isSelected ? AppTheme.primary :
            AppTheme.textSecondary
        )
    }
}
