//
//  FuelListView.swift
//  Fuel
//
//  Created by Dariusz Baranczuk on 07/10/2024.
//

import SwiftUI
import Foundation
import HomeStorage
import SwiftData
import Charts

struct FuelListView: View {
    
    @StateObject private var fuelViewModel: FuelViewModel
    @State private var inProgress: Bool = false
    @State private var addSheetVisible: Bool = false
    @State private var showDeleteDialog: Bool = false
    @State private var entryToDelete: FuelEntry? = nil
    
    init(modelContext: ModelContext) {
        _fuelViewModel = StateObject(wrappedValue: FuelViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if inProgress {
                    ProgressView()
                } else {
                    if fuelViewModel.entries.isEmpty {
                        Button {
                            inProgress = true
                            fuelViewModel.importEntries {
                                inProgress = false
                            }
                        } label: {
                            Text("Import")
                        }
                        
                    } else {
                        let (minPrice, maxPrice) = fuelViewModel.minMaxConstPerLister()
                        VStack {
                            Chart {
                                ForEach(Array(fuelViewModel.entries.enumerated()), id: \.element) { index, entry in
                                    LineMark(
                                        x: .value("date", index),
                                        y: .value("cost", (entry.cost / entry.liters))
                                    )
                                    .lineStyle(StrokeStyle(lineWidth: 1))
                                    .foregroundStyle(Color.green) // entry.type == 1 ? Color.green : Color.black)
                                }
                            }
                            .frame(height: 100)
                            .chartYScale(domain: minPrice...maxPrice)
                            .chartXScale(domain: 0...fuelViewModel.entries.count)
                            
                            Divider()
                            
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 4) {
                                    ForEach(fuelViewModel.entries.reversed(), id: \.self) { entry in
                                        EntryView(entry)
                                            .onLongPressGesture {
                                                entryToDelete = entry
                                                showDeleteDialog = true
                                            }
                                    }
                                }
                            }
                        }
                        
                    }
                    
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { addSheetVisible = true })  {
                        Text("Add")
                    }
                }
            }
            .sheet(isPresented: $addSheetVisible) {
                NewEntryView(viewModel: fuelViewModel)
                    .presentationDetents([.height(350)])
            }
            .alert(isPresented: $showDeleteDialog) {
                deleteAlert()
            }
            .task {
                inProgress = true
                defer { inProgress = false }
                await fuelViewModel.fetchAll()
            }
        }
    }
    
    private func deleteAlert() -> Alert {
        return Alert(
            title: Text("Delete?"),
            message: Text("Delete \(String(format: "%.2fzł", entryToDelete?.cost ?? 0)) / \(String(format: "%.2fzł", entryToDelete?.liters ?? 0))L ?"),
            primaryButton: .destructive(Text("Yes")) {
                guard let entry = entryToDelete else { return }
                deleteEntry(entry: entry)
            },
            secondaryButton: .cancel()
        )
    }
    
    private func deleteEntry(entry: FuelEntry) {
        Task {
            inProgress = true
            defer { inProgress = false }
            await fuelViewModel.deleteEntry(entry: entry)
        }
    }
    
    fileprivate func EntryView(_ entry: ReversedCollection<[FuelEntry]>.Element) -> some View {
        return HStack {
            Image(entry.type == 0 ? "ic_diesel" : "ic_fuel95")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
                .padding(.trailing, 4)
                .padding(.leading, 4)
                .padding(.top, 4)
            
            VStack(alignment: .leading) {
                Text("\(String(format: "%.2fzł", entry.cost)) / \(String(format: "%.2fzł", entry.liters))L")
                    .bold()
                    .font(.system(size: 12))
                Text(String(format: "%.2fzł/L", entry.cost / entry.liters))
                    .font(.system(size: 12))
            }
            .padding(.top, 4)
            
            Text(entry.formattedDate(fuelViewModel.dateFormatter))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 4)
                .font(.system(size: 12))
        }
        .frame(maxWidth: .infinity)
    }
}
