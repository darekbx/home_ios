//
//  TasksViewController.swift
//  Tasks
//
//  Created by Dariusz Baranczuk on 15/09/2024.
//

import Foundation
import HomeStorage
import SwiftData

class TasksViewController: ObservableObject {
    
    @Published var inProgress: Bool = false
    @Published var tasks: [Task] = []
    
    private let databaseManager = DatabaseManager()
    
    public func fetchAllTasks(modelContext: ModelContext) {
        tasks = databaseManager.fetchAllTasks(modelContext: modelContext)
    }
    
    func importTasks(modelContext: ModelContext) {
        inProgress = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.databaseManager.openDatabase()
            self.databaseManager.importTasks(modelContext: modelContext)
            self.databaseManager.close()
            
            Thread.sleep(forTimeInterval: 1.0)
            
            DispatchQueue.main.async {
                self.inProgress = false
                self.fetchAllTasks(modelContext: modelContext)
            }
        }
    }
    
}
