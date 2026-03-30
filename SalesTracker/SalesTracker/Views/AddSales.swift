//
//  AddSales.swift
//  SalesTracker
//
//  Created by 澤口楓斗 on 2026/03/30.
//

import SwiftUI
import SwiftData

struct AddSalesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedWeek = 1
    @State private var amount = ""

    let years = Array(2020...2030)
    let months = Array(1...12)
    let weeks = Array(1...5)

    var body: some View {
        NavigationStack {
            Form {
                Section("期間") {
                    Picker("年", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text("\(year)年").tag(year)
                        }
                    }
                    Picker("月", selection: $selectedMonth) {
                        ForEach(months, id: \.self) { month in
                            Text("\(month)月").tag(month)
                        }
                    }
                    Picker("週", selection: $selectedWeek) {
                        ForEach(weeks, id: \.self) { week in
                            Text("第\(week)週").tag(week)
                        }
                    }
                }

                Section("売上金額") {
                    HStack {
                        Text("¥")
                        TextField("金額を入力", text: $amount)
                            .keyboardType(.numberPad)
                    }
                }
            }
            .navigationTitle("売上を追加")
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
                    .disabled(amount.isEmpty)
                }
            }
        }
    }

    private func saveRecord() {
        guard let amountValue = Double(amount) else { return }
        let record = SalesRecord(
            year: selectedYear,
            month: selectedMonth,
            week: selectedWeek,
            amount: amountValue
        )
        modelContext.insert(record)
        dismiss()
    }
}
