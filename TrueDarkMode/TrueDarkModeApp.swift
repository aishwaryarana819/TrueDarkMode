//
//  DarkModeApp.swift
//  DarkMode
//
//  Created by Aishwarya Rana on 09/02/26.
//

import SwiftUI

@main
struct TrueDarkModeApp: App {
    @StateObject var appState = AppState.shared
    @AppStorage("hasLaunchedBefore") var hasLaunchedBefore: Bool = false
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
        } label: {
            Image(appState.isDarkMode ? "MenuBarIconDark" : "MenuBarIconLight")
        }
        .menuBarExtraStyle(.window)
        
        Window("TrueDarkMode Settings", id: "settings-window") {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    hasLaunchedBefore = true
                }
        }
        .windowResizability(.contentSize)
    }
}
