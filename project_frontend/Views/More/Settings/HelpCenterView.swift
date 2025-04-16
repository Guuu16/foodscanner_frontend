import SwiftUI

struct HelpCenterView: View {
    let faqs = [
        FAQ(question: "How do I track my daily calories?",
            answer: "You can track your daily calories by logging your meals in the Food Diary section. Simply tap the '+' button and search for your food items or scan their barcodes."),
        FAQ(question: "How do I set my fitness goals?",
            answer: "Go to More > Health Goals to set your target weight, daily calorie goals, and weekly workout targets. You can also customize your dietary preferences and restrictions."),
        FAQ(question: "How do I sync with other health apps?",
            answer: "Navigate to Settings > Connected Apps to manage your app connections. We support integration with Apple Health and other popular fitness apps."),
        FAQ(question: "How can I export my data?",
            answer: "You can export your health and nutrition data by going to Settings > Privacy > Export Data. Your data will be exported in CSV format.")
    ]
    
    @State private var searchText = ""
    
    var filteredFAQs: [FAQ] {
        if searchText.isEmpty {
            return faqs
        } else {
            return faqs.filter { $0.question.localizedCaseInsensitiveContains(searchText) || 
                               $0.answer.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        List {
            Section {
                TextField("Search help topics", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 8)
            }
            
            Section(header: Text("Frequently Asked Questions")) {
                ForEach(filteredFAQs) { faq in
                    DisclosureGroup(
                        content: {
                            Text(faq.answer)
                                .padding(.vertical, 8)
                        },
                        label: {
                            Text(faq.question)
                                .font(.headline)
                        }
                    )
                }
            }
            
            Section {
                Link(destination: URL(string: "mailto:support@example.com")!) {
                    HStack {
                        Image(systemName: "envelope.fill")
                        Text("Contact Support")
                    }
                }
                
                Link(destination: URL(string: "https://example.com/support")!) {
                    HStack {
                        Image(systemName: "safari.fill")
                        Text("Visit Support Center")
                    }
                }
            }
        }
        .navigationTitle("Help Center")
    }
}

struct FAQ: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}
