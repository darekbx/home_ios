//
//  WeightManager.swift
//  HomeStorage
//
//  Created by Dariusz Baranczuk on 17/09/2024.
//

import Foundation
import SwiftData
import SQLite3

public enum EntryType: Int8 {
    case monika = 1
    case darek = 2
    case michal = 3
}

@ModelActor
public actor WeightManager {
    
    public func fetchAllEntries() async -> [WeightEntry] {
        let descriptor = FetchDescriptor<WeightEntry>()
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Fetch error \(error)")
            return []
        }
    }
    
    public func fetchAllEntries(entryType: EntryType) async -> [WeightEntry] {
        let rawType = entryType.rawValue
        let predicate = #Predicate<WeightEntry> {
            $0.type == rawType
        }
        let sort = [SortDescriptor(\WeightEntry.date, order: .reverse)]
        let descriptor = FetchDescriptor<WeightEntry>(predicate: predicate, sortBy: sort)
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Fetch error \(error)")
            return []
        }
    }
    
    public func addEntry(entry: WeightEntry) async {
        modelContext.insert(entry)
    }
    
    public func deleteEntry(entry: WeightEntry) async {
        modelContext.delete(entry)
    }
}

public class EntriesImport: DatabaseManager {
    public func importEntries(modelContext: ModelContext) {
        openDatabase { db in
            let query = "SELECT date, weight, type FROM weight_entry"
            var queryStatement: OpaquePointer?
            
            if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let date = sqlite3_column_int64(queryStatement, 0)
                    let weight = sqlite3_column_double(queryStatement, 1)
                    let type = sqlite3_column_int(queryStatement, 2)
                    modelContext.insert(WeightEntry(date: date, weight: weight, type: Int8(type)))
                }
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Query failed: \(errorMessage)")
            }
            
            // Clean up
            sqlite3_finalize(queryStatement)
        }
    }
}
