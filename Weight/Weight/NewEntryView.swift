//
//  NewEntryView.swift
//  Weight
//
//  Created by Dariusz Baranczuk on 01/10/2024.
//

import SwiftUI
import HomeStorage
import SwiftData
import Foundation

struct NewEntryView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var weightViewModel: WeightViewModel
    @State private var weight: Double = 0
    @State private var selectedOption: Int = 0
    @FocusState private var isTextFieldFocused: Bool
    
    private var numberFormatter = NumberFormatter()
    
    init(weightViewModel: WeightViewModel) {
        self.weightViewModel = weightViewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Weight", value: $weight, formatter: numberFormatter)
                    .keyboardType(.decimalPad)
                    .focused($isTextFieldFocused)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Picker("", selection: $selectedOption) {
                    Text("Monika").tag(0)
                    Text("Darek").tag(1)
                    Text("Michał").tag(2)
                }
                .pickerStyle(.segmented)
            }
            .navigationTitle("New entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addEntry(weight: weight, selectedOption: selectedOption) {
                            dismiss()
                        }
                    }
                }
            }
            .padding()
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
    
    private func addEntry(weight: Double, selectedOption: Int, onDone: @escaping () -> Void) {
        Task {
            await weightViewModel.add(weight: weight, selectedOption: Int8(selectedOption))
            onDone()
        }
    }
}
