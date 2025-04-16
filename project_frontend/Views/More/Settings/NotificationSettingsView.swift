import SwiftUI

struct NotificationSettingsView: View {
    @AppStorage("pushNotifications") private var pushNotifications = true
    @AppStorage("emailNotifications") private var emailNotifications = true
    @AppStorage("dailyReminder") private var dailyReminder = true
    @AppStorage("weeklyReport") private var weeklyReport = true
    
    var body: some View {
        Form {
            Section(header: Text("General")) {
                Toggle("Push Notifications", isOn: $pushNotifications)
                Toggle("Email Notifications", isOn: $emailNotifications)
            }
            
            Section(header: Text("Reminders")) {
                Toggle("Daily Calorie Reminder", isOn: $dailyReminder)
                Toggle("Weekly Progress Report", isOn: $weeklyReport)
            }
            
            Section(footer: Text("Turn on notifications to stay updated with your nutrition goals and progress.")) {
                // Additional settings if needed
            }
        }
        .navigationTitle("Notifications")
    }
}
