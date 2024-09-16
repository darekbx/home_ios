//
//  TaskDetails.swift
//  Tasks
//
//  Created by Dariusz Baranczuk on 16/09/2024.
//

import Foundation
import SwiftUI
import HomeStorage

struct TaskDetailsView: View {
    let task: Task
    
    var body: some View {
        ScrollView {
            Text(task.content)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .navigationTitle(task.name)
    }
}
