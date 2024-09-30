//
//  ContentView.swift
//  Weight
//
//  Created by Dariusz Baranczuk on 17/09/2024.
//

import SwiftUI
import HomeStorage
import SwiftData
import Foundation

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View{
        ChartView(modelContext: modelContext)
    }
}

struct ChartView: View {
    
    @StateObject private var weightViewModel: WeightViewModel
    @State private var inProgress: Bool = false
    
    init(modelContext: ModelContext) {
        _weightViewModel = StateObject(wrappedValue: WeightViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if inProgress || weightViewModel.inProgress {
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
            .navigationTitle("Weight")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: EntriesList()) {
                        Text("List")
                    }
                }
            }
            .task {
                self.inProgress = true
                defer { self.inProgress = false }
                
                await weightViewModel.fetchEntries(entryType: EntryType.darek)
                await weightViewModel.fetchEntries(entryType: EntryType.monika)
                await weightViewModel.fetchEntries(entryType: EntryType.michal)
                
                try? await _Concurrency.Task.sleep(nanoseconds: 500_000_000)
            }
            .onDisappear {
                weightViewModel.clear()
            }
            .padding()
        }
        
    }
}
