import SwiftUI

struct AppearanceSettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("useSystemTheme") private var useSystemTheme = true
    @AppStorage("fontSize") private var fontSize: Double = 1.0
    @Environment(\.colorScheme) var systemColorScheme
    
    let fontSizes = ["Small", "Medium", "Large", "Extra Large"]
    let fontScales: [Double] = [0.8, 1.0, 1.2, 1.4]
    
    @State private var selectedFontSizeIndex: Int = 1
    
    var body: some View {
        Form {
            Section(header: Text("Theme")) {
                Toggle("Use System Theme", isOn: $useSystemTheme)
                    .onChange(of: useSystemTheme) { newValue in
                        if newValue {
                            isDarkMode = systemColorScheme == .dark
                        }
                    }
                
                if !useSystemTheme {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                }
            }
        } 
        //     Section(header: Text("Text Size")) {
        //         Picker("Font Size", selection: $selectedFontSizeIndex) {
        //             ForEach(0..<fontSizes.count, id: \.self) { index in
        //                 Text(fontSizes[index])
        //             }
        //         }
        //         .onChange(of: selectedFontSizeIndex) { newValue in
        //             fontSize = fontScales[newValue]
        //             UserDefaults.standard.set(fontSize, forKey: "fontSize")
        //         }
        //     }
            
        //     Section(header: Text("Preview"), footer: Text("These settings will affect how the app appears on your device.")) {
        //         VStack(alignment: .leading, spacing: 10) {
        //             Text("Heading Text")
        //                 .font(.system(size: 20 * fontSize))
        //                 .fontWeight(.bold)
        //             Text("This is a preview of how the text will appear in the app.")
        //                 .font(.system(size: 16 * fontSize))
        //         }
        //         .padding(.vertical, 8)
        //     }
        // }
        .navigationTitle("Appearance")
        .onAppear {
            if let index = fontScales.firstIndex(of: fontSize) {
                selectedFontSizeIndex = index
            }
        }
        .preferredColorScheme(useSystemTheme ? nil : (isDarkMode ? .dark : .light))
    }
}

// Preview provider for SwiftUI canvas
struct AppearanceSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AppearanceSettingsView()
        }
    }
}
