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
    
    public init() { }
    
    func openDatabase(action: (OpaquePointer) -> Void){
        let url = Bundle(for: DatabaseManager.self).url(forResource: projectDatabaseName, withExtension: "sqlite")
        if let url = url {
            var db: OpaquePointer?
            if sqlite3_open(url.path, &db) == SQLITE_OK, let db = db {
                action(db)
            }
            sqlite3_close(db)
        }
    }
}
