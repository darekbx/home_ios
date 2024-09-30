//
//  Task.swift
//  HomeStorage
//
//  Created by Dariusz Baranczuk on 15/09/2024.
//

import SwiftData

@Model
public class TaskModel {
    public var id: UUID?
    public var name: String
    public var content: String
    public var date: String
    
    init(id: UUID? = nil, name: String, content: String, date: String) {
        self.id = id ?? UUID()
        self.name = name
        self.content = content
        self.date = date
    }
}
