import SwiftUI
import UIKit

struct FoodRecognitionView: View {
    @State private var selectedImage: UIImage?
    @State private var isLoading = false
    @State private var scanResult: ScanResultResponse?
    @State private var showingImagePicker = false
    @State private var sourceTypeRawValue: Int = 0
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var editedCalories: String = ""
    @State private var editedProtein: String = ""
    @State private var editedFat: String = ""
    @State private var editedCarbs: String = ""
    @State private var showingSaveConfirmation = false
    @State private var saveSuccess = false
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Image Preview
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 300)
                            .cornerRadius(12)
                    } else {
                        Image(systemName: "camera")
                            .font(.system(size: 40))
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        Button(action: {
                            print("Take Photo button tapped")
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                print("Camera is available, setting sourceTypeRawValue to 1")
                                sourceTypeRawValue = 1
                                print("Current sourceTypeRawValue: \(sourceTypeRawValue)")
                                scanResult = nil  // 清除之前的扫描结果
                                showingImagePicker = true
                            } else {
                                print("Camera is not available")
                                errorMessage = "Camera is not available on this device"
                                showError = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Take Photo")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.primary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            print("Choose Photo button tapped")
                            print("Setting sourceTypeRawValue to 0")
                            sourceTypeRawValue = 0
                            print("Current sourceTypeRawValue: \(sourceTypeRawValue)")
                            scanResult = nil  // 清除之前的扫描结果
                            showingImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "photo.fill")
                                Text("Choose Photo")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.textSecondary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    
                    // Results
                    if let result = scanResult {
                        resultView(result)
                    }
                    
                }
                .padding()
            }
            .navigationTitle("Food Recognition")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage, sourceTypeRawValue: $sourceTypeRawValue) // 使用 $sourceTypeRawValue
                    .ignoresSafeArea()
                    .onAppear {
                        print("Sheet appeared with sourceTypeRawValue: \(sourceTypeRawValue)")
                    }
            }
            .overlay(Group { if isLoading { LoadingView() }})
            .onChange(of: selectedImage) { _ in
                if let image = selectedImage {
                    Task { await processImage(image) }
                }
            }
            .alert("Error", isPresented: $showError, presenting: errorMessage) { _ in
                Button("OK", role: .cancel) {}
            } message: { message in
                Text(message)
            }
            .alert("Success", isPresented: $showingSaveConfirmation) {
                Button("OK", role: .cancel) {
                    if saveSuccess {
                        // 清除当前数据
                        selectedImage = nil
                        scanResult = nil
                        editedCalories = ""
                        editedProtein = ""
                        editedFat = ""
                        editedCarbs = ""
                    }
                }
            } message: {
                Text("Food record has been added to your daily record")
            }
        }
    }
    
    private func resultView(_ result: ScanResultResponse) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Food Info Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(result.data.foodName)
                        .font(.title2)
                        .bold()
                    Spacer()
                    RatingView(rating: Double(result.data.rating) / 2.0)
                }
                Text(result.data.type)
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            
            // Nutrition Info Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Nutritional Information")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                Group {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("\(result.data.nutritionalInfoPer100g.calories) kcal", text: $editedCalories)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .frame(width: 100)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField(String(format: "%.1fg", result.data.nutritionalInfoPer100g.protein), text: $editedProtein)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .frame(width: 100)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Fat")
                        Spacer()
                        TextField(String(format: "%.1fg", result.data.nutritionalInfoPer100g.fat), text: $editedFat)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .frame(width: 100)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Carbs")
                        Spacer()
                        TextField(String(format: "%.1fg", result.data.nutritionalInfoPer100g.carbohydrates), text: $editedCarbs)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .frame(width: 100)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            .onAppear {
                editedCalories = "\(result.data.nutritionalInfoPer100g.calories)"
                editedProtein = String(format: "%.1f", result.data.nutritionalInfoPer100g.protein)
                editedFat = String(format: "%.1f", result.data.nutritionalInfoPer100g.fat)
                editedCarbs = String(format: "%.1f", result.data.nutritionalInfoPer100g.carbohydrates)
            }
            
            
            // Brand Info Section
            if let brandInfo = result.data.brandInfo,
               let brandName = brandInfo.brandName {
                VStack(alignment: .leading, spacing: 8) {
                    Text(brandName)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    if let safetyCheck = brandInfo.safetyCheck {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(.green)
                            Text(safetyCheck.message)
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
            }
            
            // Dietary Advice Section
            if let advice = result.data.dietaryAdvice,
               !advice.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dietary Advice")
                        .font(.headline)
                    Text(advice)
                        .foregroundColor(.gray)
                        .font(.body)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
            }

            // Add Button
            Button(action: {
                Task { await saveFoodItem(result) }
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add to Daily Record")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.primary)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.top)
        }
    }
    
    private func nutritionRow(_ label: String, _ value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .foregroundColor(color)
                .bold()
        }
        .font(.system(.body))
    }
    
    private func processImage(_ image: UIImage) async {
        isLoading = true
        do {
            guard let userId = authViewModel.userId else {
                errorMessage = "Please login first"
                showError = true
                isLoading = false
                return
            }
            let (imageId, filePath) = try await APIService.uploadImage(image, userId: userId)
            let response = try await APIService.scanImage(imageId: imageId, userId: userId, filePath: filePath)
            await MainActor.run {
                scanResult = response
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
    
    private func saveFoodItem(_ result: ScanResultResponse) async {
        guard let userId = authViewModel.userId else {
            errorMessage = "Please login first"
            showError = true
            return
        }
        
        do {
            // 只提取需要的数据
            let foodData: [String: Any] = [
                "food_name": result.data.foodName,
                "calories": Double(editedCalories) ?? result.data.nutritionalInfoPer100g.calories,
                "protein": Double(editedProtein) ?? result.data.nutritionalInfoPer100g.protein,
                "fat": Double(editedFat) ?? result.data.nutritionalInfoPer100g.fat,
                "carbohydrates": Double(editedCarbs) ?? result.data.nutritionalInfoPer100g.carbohydrates,
                "type": result.data.type
            ]
            
            let jsonData = try JSONSerialization.data(withJSONObject: foodData)
            print(String(data: jsonData, encoding: .utf8)!)
            print("Image ID: \(result.imageId)")
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let request = AddFoodItemRequest(
                    imageId: Int(result.imageId),
                    description: jsonString
                )
                
                let response = try await APIService.addFoodItem(request)
                
                // 成功后清除当前数据
                DispatchQueue.main.async {
                    self.showingSaveConfirmation = true
                    self.saveSuccess = true
                    // 不要立即清除，等用户确认后清除
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to convert data to string"
                    self.showError = true
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to save food item: \(error.localizedDescription)"
                self.showError = true
            }
        }
    }
    
    struct RatingView: View {
        let rating: Double
        static let maxRating = 5
        
        var body: some View {
            HStack(spacing: 4) {
                ForEach(1...RatingView.maxRating, id: \.self) { index in
                    starView(for: index)
                }
            }
        }
        
        private func starView(for index: Int) -> some View {
            let fillAmount = rating - Double(index - 1)
            if fillAmount >= 1 {
                // 全星
                return Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            } else if fillAmount > 0 {
                // 半星
                return Image(systemName: "star.leadinghalf.filled")
                    .foregroundColor(.yellow)
            } else {
                // 空星
                return Image(systemName: "star")
                    .foregroundColor(.gray)
            }
        }
    }
    
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var image: UIImage?
        @Binding var sourceTypeRawValue: Int  // 改为 Binding
        @Environment(\.presentationMode) private var presentationMode
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            print("ImagePicker - makeUIViewController called")
            print("ImagePicker - Requested sourceType: \(sourceTypeRawValue)")
            
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            
            // 确保 sourceTypeRawValue 是有效的值
            guard let sourceType = UIImagePickerController.SourceType(rawValue: sourceTypeRawValue),
                  UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                print("ImagePicker - Invalid or unavailable source type, falling back to photo library")
                picker.sourceType = .photoLibrary
                return picker
            }
            
            picker.sourceType = sourceType
            
            // 如果是相机模式，设置额外的属性
            if sourceType == .camera {
                print("ImagePicker - Setting camera properties")
                picker.cameraCaptureMode = .photo
                picker.modalPresentationStyle = .fullScreen
            }
            
            print("ImagePicker - Final picker source type: \(picker.sourceType.rawValue)")
            return picker
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
            let parent: ImagePicker
            
            init(_ parent: ImagePicker) {
                self.parent = parent
                super.init()
            }
            
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                print("ImagePicker - Image picked with source type: \(picker.sourceType.rawValue)")
                if let image = info[.originalImage] as? UIImage {
                    parent.image = image
                }
                picker.dismiss(animated: true)
            }
            
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                print("ImagePicker - Cancelled with source type: \(picker.sourceType.rawValue)")
                picker.dismiss(animated: true)
            }
        }
    }
    
    struct LoadingView: View {
        var body: some View {
            ZStack {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text("Analyzing Image...")
                        .foregroundColor(.white)
                        .padding(.top)
                }
            }
        }
    }
    
    struct FoodRecognitionView_Previews: PreviewProvider {
        static var previews: some View {
            FoodRecognitionView()
        }
    }
}
