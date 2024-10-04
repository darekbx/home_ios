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
        entries.map { $0.count }.max() ?? 0
    }
    
    func clear() {
        entries = []
    }
    
    func add(weight: Double, selectedOption: Int8) async {
        await weightManager.addEntry(weight: weight, selectedOption: selectedOption + 1)
        if let entryType = EntryType(rawValue: selectedOption + 1) {
            entries[Int(selectedOption)].removeAll()
            await fetchEntries(entryType: entryType)
        }
    }
    
    @MainActor
    func delete(column: Int, entry: WeightEntry) async {
        await self.weightManager.deleteEntry(entry: entry)
        entries[column].removeAll { $0 == entry }
    }
    
    func fetchAll() async {
        await fetchEntries(entryType: EntryType.darek)
        await fetchEntries(entryType: EntryType.monika)
        await fetchEntries(entryType: EntryType.michal)
    }
    
    @MainActor
    func fetchEntries(entryType: EntryType) async {
        let data = await weightManager.fetchAllEntries(entryType: entryType)
        if entries.count == 3 {
            self.entries[Int(entryType.rawValue) - 1] = data
        } else {
            self.entries.append(data)
        }
    }
    
    func importEntries(done: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.entriesImport.importEntries(modelContext: self.modelContext)
            DispatchQueue.main.async {
                done()
            }
        }
    }
}
