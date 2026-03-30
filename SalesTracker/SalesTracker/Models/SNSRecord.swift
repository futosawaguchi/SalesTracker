//
//  SNSRecord.swift
//  SalesTracker
//
//  Created by 澤口楓斗 on 2026/03/30.
//

import Foundation
import SwiftData

@Model
final class SNSRecord {
    var id: UUID
    var followers: Int   // フォロワー数
    var following: Int   // フォロー数
    var recordedAt: Date // 記録した日時
    var memo: String     // メモ（任意）

    init(followers: Int, following: Int, memo: String = "") {
        self.id = UUID()
        self.followers = followers
        self.following = following
        self.recordedAt = Date()
        self.memo = memo
    }
}
