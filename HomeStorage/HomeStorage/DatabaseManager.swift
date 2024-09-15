//
//  DatabaseManager.swift
//  HomeStorage
//
//  Created by Dariusz Baranczuk on 14/09/2024.
//

import SwiftData
import SQLite3

public class DatabaseManager {
    
    private let projectDatabaseName = "home_backup"
    private var db: OpaquePointer?
    
    public init() {
    }
    
    public func openDatabase() {
        let url = Bundle(for: DatabaseManager.self).url(forResource: projectDatabaseName, withExtension: "sqlite")
        
        if let url = url {
            if sqlite3_open(url.path, &db) == SQLITE_OK {
                print("SIGMA db ok")
            } else{
                print("SIGMA db failed")
                sqlite3_close(db)
            }
        }else{
            print("SIGMA url failed")
        }
    }
    
    public func close() {
        if db != nil {
            sqlite3_close(db)
        }
    }
    
    public func fetchAllTasks(modelContext: ModelContext) -> [Task] {
        let descriptor = FetchDescriptor<Task>()
        do {
            let tasks = try modelContext.fetch(descriptor)
            return tasks
        } catch {
            print("Fetch error \(error)")
            return []
        }
    }
    
    public func importTasks(modelContext: ModelContext) {
        let query = "SELECT name, content, date FROM task"
        var queryStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            do {
                // Delete all
                try modelContext.fetch(FetchDescriptor<Task>()).forEach { task in
                    modelContext.delete(task)
                }
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    if let nameColumn = sqlite3_column_text(queryStatement, 0),
                       let contentColumn = sqlite3_column_text(queryStatement, 1),
                       let dateColumn = sqlite3_column_text(queryStatement, 2) {
                        let name = String(cString: nameColumn)
                        let content = String(cString: contentColumn)
                        let date = String(cString: dateColumn)
                        modelContext.insert(Task(name: name, content: content, date: date))
                    }
                }
            } catch {
                print("Import error \(error)")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Query failed: \(errorMessage)")
        }
        
        // Clean up
        sqlite3_finalize(queryStatement)
    }
}
