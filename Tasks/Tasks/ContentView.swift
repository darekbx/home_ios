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
    @StateObject private var tasksViewController = TasksViewModel()
    
    var body: some View {
        VStack {
            if tasksViewController.inProgress {
                ProgressView()
            } else {
                if tasksViewController.tasks.isEmpty {
                    Text("Nothing here, try to import data!")
                    Button(action: {
                        tasksViewController.importTasks(modelContext: modelContext)
                    }) {
                        Text("Import")
                    }
                } else {
                    NavigationStack {
                        List(tasksViewController.tasks, id: \.self) { task in
                            NavigationLink {
                                TaskDetailsView(task: task)
                            } label: {
                                Text(task.name)
                            }
                            .navigationTitle("Tasks")
                        }
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
