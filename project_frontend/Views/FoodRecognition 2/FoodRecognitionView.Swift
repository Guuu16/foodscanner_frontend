import SwiftUI

struct FoodRecognitionView: View {
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var recognitionResults: [FoodItem] = []
    @State private var servingSize: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1. 图片上传/拍照区域
                ImageUploadSection(
                    selectedImage: $selectedImage,
                    isImagePickerPresented: $isImagePickerPresented
                )
                
                // 2. 识别结果展示
                if !recognitionResults.isEmpty {
                    RecognitionResultsSection(
                        results: recognitionResults,
                        servingSize: $servingSize
                    )
                }
                
                // 3. 营养信息展示
                if let mainFood = recognitionResults.first {
                    NutritionInfoSection(foodItem: mainFood)
                }
                
                // 4. 健康替代建议
                if !recognitionResults.isEmpty {
                    HealthyAlternativesSection()
                }
            }
            .padding()
        }
        .navigationTitle("Food Recognition")
    }
}

// 图片上传部分
struct ImageUploadSection: View {
    @Binding var selectedImage: UIImage?
    @Binding var isImagePickerPresented: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(12)
            } else {
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    VStack {
                        Image(systemName: "camera")
                            .font(.system(size: 30))
                        Text("Take Photo or Select from Library")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            HStack {
                Button("Take Photo") {
                    // 实现拍照功能
                }
                .buttonStyle(.bordered)
                
                Button("Choose Photo") {
                    isImagePickerPresented = true
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

// 识别结果展示部分
struct RecognitionResultsSection: View {
    let results: [FoodItem]
    @Binding var servingSize: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recognition Results")
                .font(.headline)
            
            ForEach(results) { food in
                HStack {
                    Text(food.name)
                        .font(.subheadline)
                    Spacer()
                    Text("\(food.confidence)%")
                        .foregroundColor(.gray)
                }
            }
            
            // 份量输入
            HStack {
                Text("Serving Size:")
                TextField("Enter amount (g)", text: $servingSize)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// 营养信息展示部分
struct NutritionInfoSection: View {
    let foodItem: FoodItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nutrition Information")
                .font(.headline)
            
            VStack(spacing: 8) {
                NutritionRow(label: "Calories", value: "\(foodItem.calories) kcal")
                NutritionRow(label: "Protein", value: "\(foodItem.protein)g")
                NutritionRow(label: "Carbs", value: "\(foodItem.carbs)g")
                NutritionRow(label: "Fat", value: "\(foodItem.fat)g")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// 健康替代建议部分
struct HealthyAlternativesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Healthy Alternatives")
                .font(.headline)
            
            // 这里可以添加健康替代食品建议
            Text("Healthier options you might like:")
                .font(.subheadline)
            
            // 示例替代建议
            ForEach(["Option 1", "Option 2", "Option 3"], id: \.self) { option in
                HStack {
                    Image(systemName: "leaf")
                        .foregroundColor(.green)
                    Text(option)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// 营养信息行
struct NutritionRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

// 食物项模型
struct FoodItem: Identifiable {
    let id = UUID()
    let name: String
    let confidence: Int
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
}

#Preview {
    NavigationView {
        FoodRecognitionView()
    }
}