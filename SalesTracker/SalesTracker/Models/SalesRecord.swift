//
//  SalesRecord.swift
//  SalesTracker
//
//  Created by 澤口楓斗 on 2026/03/30.
//

import Foundation
import SwiftData

@Model
final class SalesRecord {
    var id: UUID
    var year: Int        // 年
    var month: Int       // 月（1〜12）
    var week: Int        // 第何週（1〜5）
    var amount: Double   // 売上金額
    var createdAt: Date  // 作成日時

    init(year: Int, month: Int, week: Int, amount: Double) {
        self.id = UUID()
        self.year = year
        self.month = month
        self.week = week
        self.amount = amount
        self.createdAt = Date()
    }
}
