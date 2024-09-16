//
//  TasksViewController.swift
//  Tasks
//
//  Created by Dariusz Baranczuk on 15/09/2024.
//

import Foundation
import HomeStorage
import SwiftData

class TasksViewModel: ObservableObject {
    
    @Published var inProgress: Bool = false
    @Published var tasks: [Task] = []
    
    private let tasksManager = TasksManager()
    
    public func fetchAllTasks(modelContext: ModelContext) {
        tasks = tasksManager.fetchAllTasks(modelContext: modelContext)
    }
    
    func importTasks(modelContext: ModelContext) {
        inProgress = true
        DispatchQueue.global(qos: .userInitiated).async {
            self.tasksManager.importTasks(modelContext: modelContext)
            DispatchQueue.main.async {
                self.inProgress = false
                self.fetchAllTasks(modelContext: modelContext)
            }
        }
    }
}
