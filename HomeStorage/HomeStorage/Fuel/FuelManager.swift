//
//  FuelManager.swift
//  HomeStorage
//
//  Created by Dariusz Baranczuk on 06/10/2024.
//

import Foundation
import SwiftData
import SQLite3

@ModelActor
public actor FuelManager {
    
    public func fetchEntries() async -> [FuelEntry] {
        let descriptor = FetchDescriptor<FuelEntry>()
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Fetche error \(error)")
            return []
        }
    }
    
    public func deleteEntry(entry: FuelEntry) {
        modelContext.delete(entry)
    }
    
}

public class FuelEntriesImport: DatabaseManager {
    public func importEntries(modelContext: ModelContext) {
        openDatabase { db in
            let query = "SELECT date, liters, cost, type FROM fuel_entry"
            var queryStatement: OpaquePointer?
            
            if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let date = sqlite3_column_text(queryStatement, 0)
                    let liters = sqlite3_column_double(queryStatement, 1)
                    let cost = sqlite3_column_double(queryStatement, 2)
                    let type = sqlite3_column_int(queryStatement, 3)
                    if let date = date {
                        modelContext.insert(FuelEntry(date: String(cString: date), liters: liters, cost: cost, type: Int8(type)))
                    }
                }
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Query failed: \(errorMessage)")
            }
            
            sqlite3_finalize(queryStatement)
        }
    }
}
