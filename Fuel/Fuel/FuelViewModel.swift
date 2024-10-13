//
//  FuelViewModel.swift
//  Fuel
//
//  Created by Dariusz Baranczuk on 07/10/2024.
//

import Foundation
import HomeStorage
import SwiftData

class FuelViewModel: ObservableObject {
    
    @Published var entries: [FuelEntry] = []
    
    private var modelContext: ModelContext
    private var fuelManager: FuelManager
    private var fuelEntriesImport: FuelEntriesImport
    
    let dateFormatter = DateFormatter()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fuelManager = FuelManager(modelContainer: modelContext.container)
        fuelEntriesImport = FuelEntriesImport()
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    func minMaxConstPerLister() -> (min: Double, max: Double) {
        let allPrices = entries.map { $0.cost / $0.liters }
        return (allPrices.min() ?? 0, allPrices.max() ?? 0)
    }
    
    @MainActor
    func fetchAll() async {
        entries = await fuelManager.fetchEntries()
    }
    
    @MainActor
    func deleteEntry(entry: FuelEntry) async {
        await fuelManager.deleteEntry(entry: entry)
        entries.removeAll { $0 == entry }
    }
    
    func importEntries(done: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.fuelEntriesImport.importEntries(modelContext: self.modelContext)
            DispatchQueue.main.async {
                done()
            }
        }
    }
}
