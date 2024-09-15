//
//  ContentView.swift
//  Tasks
//
//  Created by Dariusz Baranczuk on 14/09/2024.
//

import SwiftUI
import HomeStorage

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var tasksViewController = TasksViewController()
    
    
    
    var body: some View {
        VStack {
            
            if tasksViewController.inProgress {
                ProgressView()
            } else {
                if tasksViewController.tasks.isEmpty {
                    Text("Empty!")
                    Button(action: {
                        tasksViewController.importTasks(modelContext: modelContext)
                    }) {
                        Text("Import")
                    }
                } else {
                    List(tasksViewController.tasks, id: \.self) { task in
                        Text(task.name)
                    }
                }
            }
        }
        .onAppear {
            tasksViewController.fetchAllTasks(modelContext: modelContext)
        }
    }
}

#Preview {
    ContentView()
}
