import SwiftUI

struct NumberInputSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let title: String
    let placeholder: String
    let value: Double
    let onSave: (Double) -> Void
    
    @State private var inputText: String
    
    init(title: String, value: Double, placeholder: String, onSave: @escaping (Double) -> Void) {
        self.title = title
        self.value = value
        self.placeholder = placeholder
        self.onSave = onSave
        _inputText = State(initialValue: String(value))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField(placeholder, text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .padding()
            }
            .navigationTitle(title)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    if let number = Double(inputText) {
                        onSave(number)
                    }
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    NumberInputSheet(
        title: "Height",
        value: 170.0,
        placeholder: "Enter height in cm",
        onSave: { _ in }
    )
}
