//
//  AddReviewView.swift
//  SalesTracker
//
//  Created by 澤口楓斗 on 2026/04/02.
//

import SwiftUI
import SwiftData

struct AddReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDate = Date()
    @State private var count = ""
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

                Section("口コミ数") {
                    HStack {
                        Text("件数")
                        Spacer()
                        TextField("件数を入力", text: $count)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("メモ（任意）") {
                    TextField("メモを入力", text: $memo)
                }
            }
            .navigationTitle("口コミを記録")
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
                    .disabled(count.isEmpty)
                }
            }
        }
    }

    private func saveRecord() {
        guard let countValue = Int(count) else { return }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<ReviewRecord>(
            predicate: #Predicate { record in
                record.recordedAt >= startOfDay && record.recordedAt < endOfDay
            }
        )

        if let existingRecords = try? modelContext.fetch(descriptor),
           let existing = existingRecords.first {
            existing.count = countValue
            existing.memo = memo
            existing.recordedAt = startOfDay
        } else {
            let record = ReviewRecord(
                count: countValue,
                memo: memo,
                recordedAt: startOfDay
            )
            modelContext.insert(record)
        }
        dismiss()
    }
}
