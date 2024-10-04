//
//  WeightEntry.swift
//  HomeStorage
//
//  Created by Dariusz Baranczuk on 17/09/2024.
//

import SwiftData

@Model
public class WeightEntry {
    public var id: UUID?
    public var date: Int64
    public var weight: Double
    public var type: Int8
    
    init(id: UUID? = nil, date: Int64, weight: Double, type: Int8) {
        self.id = id
        self.date = date
        self.weight = weight
        self.type = type
    }
    
    public func formattedDate(_ formatter: DateFormatter) -> String {
        let dateObject = Date(timeIntervalSince1970: TimeInterval(self.date) / 1000)
        return formatter.string(from: dateObject)
    }
}
