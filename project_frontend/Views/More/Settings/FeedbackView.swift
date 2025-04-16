import SwiftUI

struct FeedbackView: View {
    @State private var feedbackType = 0
    @State private var feedbackText = ""
    @State private var includeScreenshot = false
    @State private var showingImagePicker = false
    @State private var screenshot: UIImage?
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
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            if let screenshot = screenshot {
                                Image(uiImage: screenshot)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                            } else {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                    .frame(height: 100)
                            }
                        }
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
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $screenshot)
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
