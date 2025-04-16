import SwiftUI

struct TextInputSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let title: String
    let placeholder: String
    let value: String
    let onSave: (String) -> Void
    
    @State private var inputText: String
    
    init(title: String, value: String, placeholder: String, onSave: @escaping (String) -> Void) {
        self.title = title
        self.value = value
        self.placeholder = placeholder
        self.onSave = onSave
        _inputText = State(initialValue: value)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField(placeholder, text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            .navigationTitle(title)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    onSave(inputText)
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    TextInputSheet(
        title: "Name",
        value: "John Doe",
        placeholder: "Enter your name",
        onSave: { _ in }
    )
}
