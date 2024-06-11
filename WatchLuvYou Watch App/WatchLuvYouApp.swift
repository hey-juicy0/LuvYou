//
//  WatchLuvYouApp.swift
//  WatchLuvYou Watch App
//
//  Created by Jeewoo Yim on 5/15/24.
//

import SwiftUI
import Firebase
@main
struct WatchLuvYou_Watch_AppApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            TabView {
                // 첫 번째 탭에 ContentView 표시
                ContentView()
                    .tag(1)
                TextView()
                    .tag(2)
                // 두 번째 탭에 SettingsView 표시
                SettingsView()
                    .tag(3)
                
            }
        }
    }
}
