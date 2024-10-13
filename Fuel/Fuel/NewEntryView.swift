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
    
    init(viewModel: FuelViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Text("TODO")
    }
    
}
