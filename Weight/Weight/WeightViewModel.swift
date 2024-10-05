//
//  WeightViewModel.swift
//  Weight
//
//  Created by Dariusz Baranczuk on 17/09/2024.
//

import Foundation
import HomeStorage
import SwiftData

class WeightViewModel: ObservableObject {
    
    @Published var entries: [[WeightEntry]] = [[], [], []]
    
    private var weightManager: WeightManager
    private var entriesImport: EntriesImport
    private var modelContext: ModelContext
    
    let dateFormatter = DateFormatter()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        weightManager = WeightManager(modelContainer: modelContext.container)
        entriesImport = EntriesImport()
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    func maxCount() -> Int {
        entries.map { $0.count }.max() ?? 0
    }
    
    func minMaxDate() -> (min: Int64, max: Int64) {
        let allDates = entries.flatMap { $0.map { $0.date} }
        return (allDates.min() ?? 0, allDates.max() ?? 0)
    }
    
    func minMaxWeight() -> (min: Double, max: Double) {
        let allWeights = entries.flatMap { $0.map { $0.weight} }
        return (allWeights.min() ?? 0, allWeights.max() ?? 0)
    }
    
    func clear() {
        entries = []
    }
    
    @MainActor
    func add(weight: Double, selectedOption: Int8) async {
        await weightManager.addEntry(weight: weight, selectedOption: selectedOption + 1)
        if let entryType = EntryType(rawValue: selectedOption + 1) {
            await fetchEntries(entryType: entryType)
        }
    }
    
    @MainActor
    func delete(column: Int, entry: WeightEntry) async {
        await weightManager.deleteEntry(entry: entry)
        entries[column].removeAll { $0 == entry }
    }
    
    @MainActor
    func fetchAll() async {
        for type in EntryType.allCases {
            await fetchEntries(entryType: type)
        }
        try? await Task.sleep(nanoseconds: 1)
    }
    
    @MainActor
    func fetchEntries(entryType: EntryType) async {
        let data = await weightManager.fetchAllEntries(entryType: entryType)
        if entries.count == 3 {
            entries[Int(entryType.rawValue) - 1] = data
        } else {
            entries.append(data)
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
