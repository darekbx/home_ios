//
//  TasksApp.swift
//  Tasks
//
//  Created by Dariusz Baranczuk on 14/09/2024.
//

import SwiftUI
import SwiftData
import HomeStorage

@main
struct TasksApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [TaskModel.self])
        }
    }
}
