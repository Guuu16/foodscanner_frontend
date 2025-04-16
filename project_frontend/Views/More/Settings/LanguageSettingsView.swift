import SwiftUI

struct LanguageSettingsView: View {
    @State private var selectedLanguage = "English"
    let languages = ["English", "简体中文", "繁體中文"]
    
    var body: some View {
        Form {
            Section {
                Picker("Language", selection: $selectedLanguage) {
                    ForEach(languages, id: \.self) { language in
                        Text(language)
                    }
                }
            }
            
            Section(footer: Text("Changes will take effect after restarting the app.")) {
                // Additional settings if needed
            }
        }
        .navigationTitle("Language")
    }
}
