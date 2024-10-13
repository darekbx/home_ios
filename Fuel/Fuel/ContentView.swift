//
//  ContentView.swift
//  Fuel
//
//  Created by Dariusz Baranczuk on 06/10/2024.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        FuelListView(modelContext: modelContext)
    }
}
