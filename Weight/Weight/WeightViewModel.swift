//
//  WeightViewModek.swift
//  Weight
//
//  Created by Dariusz Baranczuk on 17/09/2024.
//

import Foundation
import HomeStorage
import SwiftData

class WeightViewModel: ObservableObject {
    
    @Published var inProgress: Bool = false
    @Published var entries: [[WeightEntry]] = []
    
    private var weightManager: WeightManager
    private var entriesImport: EntriesImport
    private var modelContext: ModelContext
    
    let dateFormatter = DateFormatter()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.weightManager = WeightManager(modelContainer: modelContext.container)
        self.entriesImport = EntriesImport()
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    func maxCount() -> Int {
        return entries.map({ $0.count }).max() ?? 0
    }
    
    func clear() {
        self.entries = []
    }
    
    func delete(column: Int, entry: WeightEntry) async {
        await self.weightManager.deleteEntry(entry: entry)
        await MainActor.run {
            entries[column].removeAll { $0 == entry }
        }
    }
    
    func fetchEntries(entryType: EntryType) async {
        let data = await self.weightManager.fetchAllEntries(entryType: entryType)
        await MainActor.run {
            self.entries.append(data)
        }
    }
    
    func importEntries() {
        inProgress = true
        DispatchQueue.global(qos: .userInitiated).async {
            self.entriesImport.importEntries(modelContext: self.modelContext)
            DispatchQueue.main.async {
                self.inProgress = false
            }
        }
    }
}
