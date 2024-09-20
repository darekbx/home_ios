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
    @StateObject private var tasksViewModel = TasksViewModel()
    
    var body: some View {
        VStack {
            if tasksViewModel.inProgress {
                ProgressView()
            } else {
                if tasksViewModel.tasks.isEmpty {
                    Text("Nothing here, try to import data!")
                    Button(action: {
                        tasksViewModel.importTasks(modelContext: modelContext)
                    }) {
                        Text("Import")
                    }
                } else {
                    NavigationStack {
                        List(tasksViewModel.tasks, id: \.self) { task in
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
            tasksViewModel.fetchAllTasks(modelContext: modelContext)
        }
    }
}

#Preview {
    ContentView()
}
