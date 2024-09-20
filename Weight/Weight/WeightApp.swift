//
//  WeightApp.swift
//  Weight
//
//  Created by Dariusz Baranczuk on 17/09/2024.
//

import SwiftUI
import SwiftData
import HomeStorage

@main
struct WeightApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [WeightEntry.self])
        }
    }
}
