//
//  ChartView.swift
//  Weight
//
//  Created by Dariusz Baranczuk on 04/10/2024.
//

import SwiftUI
import HomeStorage
import SwiftData
import Foundation
import Charts

struct ChartView: View {
    
    @StateObject private var weightViewModel: WeightViewModel
    @State private var inProgress: Bool = false
    @State private var addSheetVisible: Bool = false
    
    private let colors = [
        Color.pink,
        Color.blue,
        Color.green
    ]
    
    private let types = [
        "Monika",
        "Darek",
        "Michał",
    ]
    
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
                        let (minDate, maxDate) = weightViewModel.minMaxDate()
                        let (minWeight, maxWeight) = weightViewModel.minMaxWeight()
                        Chart {
                            ForEach(Array(weightViewModel.entries.enumerated()), id: \.element) { index, group in
                                ForEach(group, id: \.self) { entry in
                                    LineMark(
                                        x: .value("date", entry.date),
                                        y: .value(types[index], entry.weight)
                                    )
                                    .lineStyle(StrokeStyle(lineWidth: 1))
                                    .foregroundStyle(colors[index])
                                }
                                .foregroundStyle(by: .value("date", types[index]))
                            }
                        }
                        .chartForegroundStyleScale(KeyValuePairs(dictionaryLiteral:
                            (types[0], colors[0]),
                            (types[1], colors[1]),
                            (types[2], colors[2])
                        ))
                        .chartYAxis {
                            AxisMarks(values: .stride(by: 5)) { value in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel() {
                                    if let doubleValue = value.as(Double.self) {
                                        Text("\(Int(doubleValue))kg")
                                    }
                                }
                            }
                        }
                        .chartXAxis(.hidden)
                        .chartXScale(domain: minDate...maxDate)
                        .chartYScale(domain: (minWeight - 1)...(maxWeight + 1))
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
