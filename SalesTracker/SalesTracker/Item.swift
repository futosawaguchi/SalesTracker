//
//  Item.swift
//  SalesTracker
//
//  Created by 澤口楓斗 on 2026/03/30.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
