//
//  project_frontendApp.swift
//  project_frontend
//
//  Created by 顾杰 on 2024/12/4.
//

import SwiftUI

@main
struct project_frontendApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("useSystemTheme") private var useSystemTheme = true
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(useSystemTheme ? nil : (isDarkMode ? .dark : .light))
        }
    }
}
