import SwiftUI

struct NumberPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var value: Double
    let title: String
    let unit: String
    let range: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        NavigationView {
            VStack {
                Picker(title, selection: $value) {
                    ForEach(Array(stride(from: range.lowerBound, through: range.upperBound, by: step)), id: \.self) { number in
                        Text(String(format: "%.1f \(unit)", number))
                            .tag(number)
                    }
                }
                .pickerStyle(.wheel)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NumberPickerSheet(
        value: .constant(170.0),
        title: "Height",
        unit: "cm",
        range: 100...250,
        step: 0.5
    )
}
