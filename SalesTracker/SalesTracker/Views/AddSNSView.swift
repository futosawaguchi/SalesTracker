//
//  AddSNSView.swift
//  SalesTracker
//
//  Created by 澤口楓斗 on 2026/04/02.
//

import SwiftUI
import SwiftData

struct AddSNSView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var followers = ""
    @State private var following = ""
    @State private var memo = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("フォロワー数") {
                    HStack {
                        Text("フォロワー")
                        Spacer()
                        TextField("人数を入力", text: $followers)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("フォロー中")
                        Spacer()
                        TextField("人数を入力", text: $following)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("メモ（任意）") {
                    TextField("メモを入力", text: $memo)
                }
            }
            .navigationTitle("Instagramを記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveRecord()
                    }
                    .disabled(followers.isEmpty || following.isEmpty)
                }
            }
        }
    }

    private func saveRecord() {
        guard let followersValue = Int(followers),
              let followingValue = Int(following) else { return }
        
        // 今日の日付の開始・終了を取得
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // 今日すでに記録があるか確認してコンテキストから取得
        let existingRecord = modelContext.registeredModel(
            for: SNSRecord.self
        )
        
        // SwiftDataで今日のレコードを検索
        let descriptor = FetchDescriptor<SNSRecord>(
            predicate: #Predicate { record in
                record.recordedAt >= startOfDay && record.recordedAt < endOfDay
            }
        )
        
        if let todayRecords = try? modelContext.fetch(descriptor),
           let existing = todayRecords.first {
            // 既存レコードを上書き
            existing.followers = followersValue
            existing.following = followingValue
            existing.memo = memo
            existing.recordedAt = Date()
        } else {
            // 新規作成
            let record = SNSRecord(
                followers: followersValue,
                following: followingValue,
                memo: memo
            )
            modelContext.insert(record)
        }
        dismiss()
    }
}
