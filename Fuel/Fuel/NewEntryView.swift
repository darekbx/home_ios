//
//  NewEntryView.swift
//  Fuel
//
//  Created by Dariusz Baranczuk on 11/10/2024.
//

import SwiftUI
import HomeStorage
import SwiftData
import Foundation

struct NewEntryView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var viewModel: FuelViewModel
    
    @State private var price: Double = 0
    @State private var liters: Double = 0
    @State private var type: Int = 1
    
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.zeroSymbol = ""
        formatter.nilSymbol = ""
        return formatter
    }()
    
    init(viewModel: FuelViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            Form {
                VStack {
                    TextField("Price", value: $price, formatter: formatter)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Liters", value: $liters, formatter: formatter)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("", selection: $type) {
                        Text("Diesel").tag(0)
                        Text("95").tag(1)
                        
                    }.pickerStyle(.segmented)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addEntry() {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private func addEntry(onDone: @escaping () -> Void) {
        Task {
            await viewModel.add(price: price, liters: liters, type: type)
            onDone()
        }
    }
}
