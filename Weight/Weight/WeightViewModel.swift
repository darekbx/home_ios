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
    
    private let weightManager = WeightManager()
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchEntries(entryType: EntryType) {
        inProgress = true
        DispatchQueue.global(qos: .background).async {
            let data = self.weightManager.fetchAllEntries(modelContext: self.modelContext, entryType: entryType)
            DispatchQueue.main.async {
                self.entries.append(data)
                self.inProgress = false
            }
        }
    }
    
    func importEntries() {
        inProgress = true
        DispatchQueue.global(qos: .userInitiated).async {
            self.weightManager.importEntries(modelContext: self.modelContext)
            DispatchQueue.main.async {
                self.inProgress = false
            }
        }
    }
}
