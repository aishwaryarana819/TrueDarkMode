//
//  ContentView.swift
//  DarkMode
//
//  Created by Aishwarya Rana on 09/02/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                VStack() {
                    WallpaperDropZone(title: "Light Wallpaper", path: $appState.lightWallpaperPath)
                    Text("Light Mode Wallpaper").foregroundStyle(.secondary)
                }
                VStack() {
                    WallpaperDropZone(title: "Dark Wallpaper", path: $appState.darkWallpaperPath)
                    Text("Dark Mode Wallpaper").foregroundStyle(.secondary)
                }
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Preferences")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
                
                Toggle("Start at Login", isOn: $appState.startAtLogin)
                
                Divider()
                
                Text("When TrueDarkMode is toggled:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Toggle("Toggle Basic Dark Mode", isOn: $appState.configSystemDark)
                Toggle("Toggle Icons & Widgets", isOn: $appState.configIcons)
                Toggle("Toggle Wallpaper", isOn: $appState.configWallpaper)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            Spacer()
            
            Button("Quit TrueDarkMode") {
                appState.quitApp()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .padding(.bottom)
        }
        .padding()
        .fixedSize()
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            appState.updateDockIcon(appState.isDarkMode)
        }
        .onDisappear {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("TrueDarkMode")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    openWindow(id: "settings-window")
                    NSApp.activate(ignoringOtherApps: true)
                }) {
                    Image(systemName: "gearshape.fill")
                }
                .buttonStyle(.plain)
                
                Button(action: { appState.quitApp() }) {
                    Image(systemName: "power.circle.fill")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
            
            GroupBox {
                HStack {
                    Text("Mode")
                    Spacer()
                    Toggle("", isOn: $appState.isDarkMode)
                        .toggleStyle(.switch)
                        .labelsHidden()
                }
            }
        }
        .padding()
        .frame(width: 220)
    }
}

struct WallpaperDropZone: View {
    let title: String
    @Binding var path: String
    @State private var isTargeted = false
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isTargeted ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                if !path.isEmpty {
                    if let image = NSImage(contentsOfFile: path) {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 140, height: 140)
                            .cornerRadius(12)
                            .clipped()
                    } else {
                        Text(URL(fileURLWithPath: path).lastPathComponent)
                            .font(.caption)
                    }
                } else {
                    Text("Drag & Drop\n\(title)")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 150, height: 150)
            .onDrop(of: [UTType.fileURL], isTargeted: $isTargeted) { providers in
                guard let provider = providers.first else { return false }
                provider.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { data, _ in
                    if let data = data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                        DispatchQueue.main.async {
                            self.path = url.path
                        }
                    }
                }
                return true
            }
            .onTapGesture {
                let panel = NSOpenPanel()
                panel.allowedContentTypes = [.image]
                panel.allowsMultipleSelection = false
                if panel.runModal() == .OK {
                    self.path = panel.url?.path ?? ""
                }
            }
        }
    }
}
