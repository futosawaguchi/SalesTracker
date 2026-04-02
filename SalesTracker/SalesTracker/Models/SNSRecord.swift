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
    var followers: Int
    var following: Int
    var recordedAt: Date
    var memo: String

    init(followers: Int, following: Int, memo: String = "", recordedAt: Date = Date()) {
        self.id = UUID()
        self.followers = followers
        self.following = following
        self.recordedAt = recordedAt
        self.memo = memo
    }
}
