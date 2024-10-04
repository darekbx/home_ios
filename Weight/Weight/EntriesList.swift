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
    @State private var entryToDelete: WeightEntry? = nil
    @State private var entryToDeleteColumn: Int? = nil
    
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
                            section(geometry: geometry)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .alert(isPresented: $showDeleteAlert) {
                    deleteAlert()
                }
            }
        }
        .task {
            self.inProgress = true
            defer { self.inProgress = false }
            await weightViewModel.fetchAll()
        }
        .onDisappear {
            weightViewModel.clear()
        }
    }
    
    private func section(geometry: GeometryProxy) -> some View {
        Section(header: EntriesHeader().frame(width: geometry.size.width)) {
            Spacer().frame(height: 6)
            ForEach(0..<weightViewModel.maxCount(), id: \.self) { index in
                HStack {
                    ForEach(0..<3) { childIndex in
                        if let entry = weightViewModel.entries[childIndex][safe: index] {
                            VStack {
                                Text(String(format: "%.1fkg", entry.weight))
                                Text(entry.formattedDate(weightViewModel.dateFormatter)).font(.caption2)
                            }
                            .onLongPressGesture {
                                entryToDelete = entry
                                entryToDeleteColumn = childIndex
                                showDeleteAlert = true
                            }
                            .frame(width: geometry.size.width * 0.33)
                        } else {
                            Spacer().frame(width: geometry.size.width * 0.33)
                        }
                    }
                }
            }
        }
    }
    
    private func deleteAlert() -> Alert {
        return Alert(
            title: Text("Delete?"),
            message: Text("Delete \(String(format: "%.1fkg", entryToDelete?.weight ?? 0.0)) item?"),
            primaryButton: .destructive(Text("Yes")) {
                if let entry = entryToDelete, let column = entryToDeleteColumn {
                    deleteEntry(column: column, entry: entry)
                }
            },
            secondaryButton: .cancel()
        )
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
