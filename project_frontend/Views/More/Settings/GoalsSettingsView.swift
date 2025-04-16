import SwiftUI

struct GoalsSettingsView: View {
    @State private var targetWeight = 65.0
    @State private var targetDate = Date()
    @State private var dailyCalorieGoal = 2000
    @State private var weeklyWorkoutGoal = 3
    
    var body: some View {
        Form {
            Section(header: Text("Weight Goal")) {
                HStack {
                    Text("Target Weight")
                    Spacer()
                    Text("\(Int(targetWeight)) kg")
                }
                Slider(value: $targetWeight, in: 40...120, step: 0.5)
                
                DatePicker("Target Date", selection: $targetDate, displayedComponents: .date)
            }
            
            Section(header: Text("Daily Goals")) {
                Stepper("Daily Calorie Goal: \(dailyCalorieGoal) kcal", 
                       value: $dailyCalorieGoal,
                       in: 1500...4000,
                       step: 50)
                
                Stepper("Weekly Workouts: \(weeklyWorkoutGoal)", 
                       value: $weeklyWorkoutGoal,
                       in: 1...7)
            }
            
            Section(footer: Text("Setting realistic goals helps maintain long-term motivation.")) {
                Button("Save Changes") {
                    // Save changes
                }
            }
        }
        .navigationTitle("Health Goals")
    }
}
