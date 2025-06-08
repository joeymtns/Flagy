//
//  FlagsApp.swift
//  Flags
//
//  Created by Martins Joé on 24/03/2025.
//

import SwiftUI

// Einstiegspunkt der App – wird beim Starten der App als Erstes aufgerufen
@main
struct FlagsApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                MainView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
