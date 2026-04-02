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

    @State private var selectedDate = Date()
    @State private var followers = ""
    @State private var following = ""
    @State private var memo = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("日付") {
                    DatePicker(
                        "記録日",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .environment(\.locale, Locale(identifier: "ja_JP"))
                }

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

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<SNSRecord>(
            predicate: #Predicate { record in
                record.recordedAt >= startOfDay && record.recordedAt < endOfDay
            }
        )

        if let existingRecords = try? modelContext.fetch(descriptor),
           let existing = existingRecords.first {
            // 既存レコードを上書き
            existing.followers = followersValue
            existing.following = followingValue
            existing.memo = memo
            existing.recordedAt = startOfDay
        } else {
            // 新規作成（selectedDateを渡す）
            let record = SNSRecord(
                followers: followersValue,
                following: followingValue,
                memo: memo,
                recordedAt: startOfDay
            )
            modelContext.insert(record)
        }
        dismiss()
    }
}
