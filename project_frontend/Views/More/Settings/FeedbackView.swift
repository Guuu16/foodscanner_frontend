import SwiftUI
import UIKit

struct FeedbackView: View {
    @State private var feedbackType = 0
    @State private var feedbackText = ""
    @State private var includeScreenshot = false
    @State private var showingImagePicker = false
    @State private var screenshot: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showError = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
    let feedbackTypes = ["Bug Report", "Feature Request", "General Feedback"]
    
    var body: some View {
        Form {
            Section(header: Text("Feedback Type")) {
                Picker("Type", selection: $feedbackType) {
                    ForEach(0..<feedbackTypes.count, id: \.self) { index in
                        Text(feedbackTypes[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("Description")) {
                TextEditor(text: $feedbackText)
                    .frame(height: 150)
            }
            
            Section {
                Toggle("Include Screenshot", isOn: $includeScreenshot)
                
                if includeScreenshot {
                    HStack {
                        Button(action: {
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                sourceType = .camera
                                showingImagePicker = true
                            } else {
                                errorMessage = "Camera is not available on this device"
                                showError = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Take Photo")
                            }
                        }
                        
                        Button(action: {
                            sourceType = .photoLibrary
                            showingImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "photo.fill")
                                Text("Choose Photo")
                            }
                        }
                    }
                    
                    if let screenshot = screenshot {
                        Image(uiImage: screenshot)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                    }
                }
            }
            
            Section {
                Button(action: submitFeedback) {
                    Text("Submit Feedback")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.blue)
            }
        }
        .navigationTitle("Send Feedback")
        // .sheet(isPresented: $showingImagePicker) {
        //     ImagePicker(image: $screenshot, sourceType: sourceType)
        //         .ignoresSafeArea()
        // }
        .alert("Error", isPresented: $showError, presenting: errorMessage) { _ in
            Button("OK", role: .cancel) {}
        } message: { message in
            Text(message)
        }
    }
    
    private func submitFeedback() {
        // Handle feedback submission
        // You can implement the API call here
        dismiss()
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FeedbackView()
        }
    }
}
