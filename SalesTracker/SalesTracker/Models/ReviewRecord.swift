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
    var count: Int       // 口コミ数
    var recordedAt: Date // 記録した日時
    var memo: String     // メモ（任意）

    init(count: Int, memo: String = "") {
        self.id = UUID()
        self.count = count
        self.recordedAt = Date()
        self.memo = memo
    }
}
