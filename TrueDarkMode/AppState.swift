//
//  AppState.swift
//  TrueDarkMode
//
//  Created by Aishwarya Rana on 11/02/26.
//

import SwiftUI
import AppKit
import Combine
import ServiceManagement

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var startAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(startAtLogin, forKey: "startAtLogin")
            if startAtLogin { try? SMAppService.mainApp.register() }
            else { try? SMAppService.mainApp.unregister() }
        }
    }
    
    @Published var configSystemDark: Bool {
        didSet { UserDefaults.standard.set(configSystemDark, forKey: "configSystemDark") }
    }
    
    @Published var configIcons: Bool {
        didSet { UserDefaults.standard.set(configIcons, forKey: "configIcons") }
    }
    
    @Published var configWallpaper: Bool {
        didSet { UserDefaults.standard.set(configWallpaper, forKey: "configWallpaper") }
    }
    
    @Published var lightWallpaperPath: String {
        didSet { UserDefaults.standard.set(lightWallpaperPath, forKey: "lightWallpaperPath") }
    }
    
    @Published var darkWallpaperPath: String {
        didSet { UserDefaults.standard.set(darkWallpaperPath, forKey: "darkWallpaperPath") }
    }
    
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
            applyTrueDarkMode(isDark: isDarkMode)
        }
    }
    
    private init() {
        self.startAtLogin = UserDefaults.standard.bool(forKey: "startAtLogin")
        self.configSystemDark = UserDefaults.standard.object(forKey: "configSystemDark") as? Bool ?? true
        self.configIcons = UserDefaults.standard.object(forKey: "configIcons") as? Bool ?? true
        self.configWallpaper = UserDefaults.standard.object(forKey: "configWallpaper") as? Bool ?? true
        self.lightWallpaperPath = UserDefaults.standard.string(forKey: "lightWallpaperPath") ?? ""
        self.darkWallpaperPath = UserDefaults.standard.string(forKey: "darkWallpaperPath") ?? ""
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        updateDockIcon(isDarkMode)
    }
    
    func applyTrueDarkMode(isDark: Bool) {
        updateDockIcon(isDark)
        
        if configSystemDark {
            toggleSystemAppearance(isDark)
        }
        
        if configIcons {
            toggleIconStyle(isDark)
        }
        
        if configWallpaper {
            updateWallpaper(isDark: isDark)
        }
    }
    
    private func toggleSystemAppearance(_ isDark: Bool) {
        let command = "osascript -e 'tell app \"System Events\" to tell appearance preferences to set dark mode to \(isDark)'"
        runShell(command)
    }
    
    private func toggleIconStyle(_ isDark: Bool) {
        let style = isDark ? "RegularDark" : "Regular"
        let command = "defaults write NSGlobalDomain AppleIconAppearanceTheme -string \"\(style)\"; killall Dock; killall SystemUIServer"
        runShell(command)
    }
    
    private func updateWallpaper(isDark: Bool) {
        let path = isDark ? darkWallpaperPath : lightWallpaperPath
        guard !path.isEmpty else { return }
        let url = URL(fileURLWithPath: path)
        
        do {
            if let screen = NSScreen.main {
               try NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
            }
        } catch {
            print("Failed to set wallpaper: \(error)")
        }
    }
    
    func updateDockIcon(_ isDark: Bool) {
        if let icon = NSImage(named: isDark ? "AppIconDark" : "AppIconLight") {
            NSApp.applicationIconImage = icon
        }
    }
    
    func quitApp() {
        NSApp.terminate(nil)
    }
    
    private func runAppleScript(_ source: String) {
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: source) {
            scriptObject.executeAndReturnError(&error)
            if let error = error {
                 print("AppleScript Error: \(error)")
            }
        }
    }
    
    private func runShell(_ command: String) {
        let task = Process()
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", command]
        task.launch()
    }
}
