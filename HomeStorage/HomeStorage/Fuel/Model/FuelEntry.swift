//
//  FuelEntry.swift
//  HomeStorage
//
//  Created by Dariusz Baranczuk on 06/10/2024.
//

import SwiftData

@Model
public class FuelEntry {
    public var id: UUID?
    public var date: String
    public var liters: Double
    public var cost: Double
    public var type: Int8
    
    init(id: UUID? = nil, date: String, liters: Double, cost: Double, type: Int8) {
        self.id = id
        self.date = date
        self.liters = liters
        self.cost = cost
        self.type = type
    }
    
    public func formattedDate(_ formatter: DateFormatter) -> String {
        let dateInt64 = (Int64(date) ?? 0) / 1000
        let dateObject = Date(timeIntervalSince1970: TimeInterval(dateInt64))
        return formatter.string(from: dateObject)
    }
}
