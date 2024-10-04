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
    @State private var addSheetVisible: Bool = false
    
    init(modelContext: ModelContext) {
        _weightViewModel = StateObject(wrappedValue: WeightViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if inProgress {
                    ProgressView()
                } else {
                    if weightViewModel.entries.isEmpty {
                        Button {
                            inProgress = true
                            weightViewModel.importEntries {
                                inProgress = false
                            }
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
            .navigationTitle("Weight chart")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: EntriesList()) {
                        Image(systemName: "list.bullet")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { addSheetVisible.toggle() })  {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $addSheetVisible) {
                NewEntryView(weightViewModel: weightViewModel)
                    .presentationDetents([.height(240)])
            }
            .task {
                self.inProgress = true
                defer { self.inProgress = false }
                await weightViewModel.fetchAll()
            }
            .onDisappear {
                weightViewModel.clear()
            }
            .padding()
        }
    }
}
