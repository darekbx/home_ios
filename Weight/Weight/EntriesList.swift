//
//  EntriesList.swift
//  Weight
//
//  Created by Dariusz Baranczuk on 21/09/2024.
//

import Foundation
import SwiftUI
import SwiftData
import HomeStorage

struct EntriesList: View {
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Entries(modelContext: modelContext)
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

fileprivate struct Entries: View {
    
    @StateObject private var weightViewModel: WeightViewModel
    @State private var inProgress: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var itemToDelete: WeightEntry? = nil
    @State private var itemToDeleteColumn: Int? = nil
    
    init(modelContext: ModelContext) {
        _weightViewModel = StateObject(wrappedValue: WeightViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        ZStack {
            if inProgress {
                ProgressView()
            } else {
                GeometryReader { geometry in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4, pinnedViews: [.sectionHeaders]) {
                            Section(header: EntriesHeader().frame(width: geometry.size.width)) {
                                Spacer().frame(height: 6)
                                ForEach(0..<weightViewModel.maxCount(), id: \.self) { index in
                                    HStack {
                                        ForEach(0..<3) { childIndex in
                                            if let element = weightViewModel.entries[childIndex][safe: index] {
                                                VStack {
                                                    let date = Date(timeIntervalSince1970: TimeInterval(element.date) / 1000)
                                                    Text(String(format: "%.1fkg", element.weight))
                                                    Text(weightViewModel.dateFormatter.string(from: date)).font(.caption2)
                                                }
                                                .onLongPressGesture {
                                                    itemToDelete = element
                                                    itemToDeleteColumn = childIndex
                                                    showDeleteAlert = true
                                                }
                                                .frame(width: geometry.size.width * 0.33)
                                            } else {
                                                Spacer()
                                                    .frame(width: geometry.size.width * 0.33)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .alert(isPresented: $showDeleteAlert) {
                    Alert(
                        title: Text("Delete?"),
                        message: Text("Delete \(String(format: "%.1fkg", itemToDelete?.weight ?? 0.0)) item?"),
                        primaryButton: .destructive(Text("Yes")) {
                            if let item = itemToDelete, let column = itemToDeleteColumn {
                                deleteEntry(column: column, entry: item)
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .task {
            self.inProgress = true
            defer { self.inProgress = false }
            
            await weightViewModel.fetchEntries(entryType: EntryType.darek)
            await weightViewModel.fetchEntries(entryType: EntryType.monika)
            await weightViewModel.fetchEntries(entryType: EntryType.michal)
        }
        .onDisappear {
            weightViewModel.clear()
        }
    }
    
    private func deleteEntry(column: Int, entry: WeightEntry) {
        Task {
            await weightViewModel.delete(column: column, entry: entry)
        }
    }
}

struct EntriesHeader: View {
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Text("Darek").fontWeight(.bold).frame(width: geometry.size.width * 0.33)
                Text("Monika").fontWeight(.bold).frame(width: geometry.size.width * 0.33)
                Text("Michał").fontWeight(.bold).frame(width: geometry.size.width * 0.33)
            }.background(.white)
        }
    }
}
