//
//  ReviewRecord.swift
//  SalesTracker
//
//  Created by 澤口楓斗 on 2026/03/30.
//

import Foundation
import SwiftData

@Model
final class ReviewRecord {
    var id: UUID
    var count: Int
    var recordedAt: Date
    var memo: String

    init(count: Int, memo: String = "", recordedAt: Date = Date()) {
        self.id = UUID()
        self.count = count
        self.recordedAt = recordedAt
        self.memo = memo
    }
}
