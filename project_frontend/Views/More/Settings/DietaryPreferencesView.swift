import SwiftUI

struct DietaryPreferencesView: View {
    @State private var selectedDiet = "None"
    @State private var allergies: Set<String> = []
    @State private var avoidIngredients: Set<String> = []
    
    let dietTypes = ["None", "Vegetarian", "Vegan", "Pescatarian", "Keto", "Paleo"]
    let commonAllergies = ["Peanuts", "Tree Nuts", "Milk", "Eggs", "Soy", "Wheat", "Fish", "Shellfish"]
    let commonAvoidances = ["Gluten", "Lactose", "Added Sugar", "Processed Foods", "Caffeine"]
    
    var body: some View {
        Form {
            Section(header: Text("Diet Type")) {
                Picker("Diet", selection: $selectedDiet) {
                    ForEach(dietTypes, id: \.self) { diet in
                        Text(diet)
                    }
                }
            }
            
            Section(header: Text("Allergies")) {
                ForEach(commonAllergies, id: \.self) { allergy in
                    Toggle(allergy, isOn: Binding(
                        get: { allergies.contains(allergy) },
                        set: { isOn in
                            if isOn {
                                allergies.insert(allergy)
                            } else {
                                allergies.remove(allergy)
                            }
                        }
                    ))
                }
            }
            
            Section(header: Text("Ingredients to Avoid")) {
                ForEach(commonAvoidances, id: \.self) { ingredient in
                    Toggle(ingredient, isOn: Binding(
                        get: { avoidIngredients.contains(ingredient) },
                        set: { isOn in
                            if isOn {
                                avoidIngredients.insert(ingredient)
                            } else {
                                avoidIngredients.remove(ingredient)
                            }
                        }
                    ))
                }
            }
            
            Section {
                Button("Save Preferences") {
                    // Save preferences
                }
            }
        }
        .navigationTitle("Dietary Preferences")
    }
}
