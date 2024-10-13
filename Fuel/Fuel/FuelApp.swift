//
//  FuelApp.swift
//  Fuel
//
//  Created by Dariusz Baranczuk on 06/10/2024.
//

import SwiftUI
import SwiftData
import HomeStorage

@main
struct FuelApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [FuelEntry.self])
        }
    }
}
