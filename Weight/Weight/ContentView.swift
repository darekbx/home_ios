//
//  ContentView.swift
//  Weight
//
//  Created by Dariusz Baranczuk on 17/09/2024.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View{
        ChartView(modelContext: modelContext)
    }
}
