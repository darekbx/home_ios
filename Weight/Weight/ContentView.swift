//
//  ContentView.swift
//  Weight
//
//  Created by Dariusz Baranczuk on 17/09/2024.
//

import SwiftUI
import HomeStorage
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View{
        ChartView(modelContext: modelContext)
    }
}

struct ChartView: View {
    
    @StateObject private var weightViewModel: WeightViewModel
    
    init(modelContext: ModelContext) {
        _weightViewModel = StateObject(wrappedValue: WeightViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        VStack {
            if weightViewModel.inProgress {
                ProgressView()
            } else {
                if weightViewModel.entries.isEmpty {
                    Button {
                        weightViewModel.importEntries()
                    } label: {
                        Text("Import")
                    }
                    
                } else {
                    ForEach(weightViewModel.entries, id: \.self) { group in
                        Text("count: \(group.count)")
                    }
                }
            }
        }
        .onAppear {
            weightViewModel.fetchEntries(entryType: EntryType.darek)
            weightViewModel.fetchEntries(entryType: EntryType.monika)
            weightViewModel.fetchEntries(entryType: EntryType.michal)
        }
        .padding()
    }
}
