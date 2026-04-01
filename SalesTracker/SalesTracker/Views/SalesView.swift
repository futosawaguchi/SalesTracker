//
//  SalesView.swift
//  SalesTracker
//
//  Created by 澤口楓斗 on 2026/03/30.
//

import SwiftUI
import SwiftData
import Charts

struct SalesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SalesRecord.year, order: .reverse) private var records: [SalesRecord]

    @State private var showingAddSheet = false
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var showChart = false

    let years = Array(2020...2030)
    let months = Array(1...12)

    // 選択中の年月のレコードだけ抽出
    var filteredRecords: [SalesRecord] {
        records.filter {
            $0.year == selectedYear && $0.month == selectedMonth
        }
    }

    // 月の合計売上を計算
    var monthlyTotal: Double {
        filteredRecords.reduce(0) { $0 + $1.amount }
    }

    // グラフ用：選択中の年の月別合計を計算
    var monthlyChartData: [(month: Int, total: Double)] {
        (1...12).map { month in
            let total = records
                .filter { $0.year == selectedYear && $0.month == month }
                .reduce(0) { $0 + $1.amount }
            return (month: month, total: total)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // 年月セレクター
                HStack {
                    Picker("年", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text("\(year)年").tag(year)
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("月", selection: $selectedMonth) {
                        ForEach(months, id: \.self) { month in
                            Text("\(month)月").tag(month)
                        }
                    }
                    .pickerStyle(.menu)

                    Spacer()

                    // グラフ切り替えボタン
                    Button(action: { showChart.toggle() }) {
                        Image(systemName: showChart ? "list.bullet" : "chart.bar.fill")
                            .font(.title2)
                    }
                }
                .padding(.horizontal)

                if showChart {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {

                            // 週別グラフ
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(selectedYear)年\(selectedMonth)月 週別売上")
                                    .font(.headline)
                                    .padding(.horizontal)

                                if filteredRecords.isEmpty {
                                    Text("この月のデータがありません")
                                        .foregroundStyle(.secondary)
                                        .padding()
                                } else {
                                    Chart(filteredRecords.sorted { $0.week < $1.week }) { record in
                                        BarMark(
                                            x: .value("週", "第\(record.week)週"),
                                            y: .value("売上", record.amount)
                                        )
                                        .foregroundStyle(.blue)
                                    }
                                    .frame(height: 200)
                                    .padding(.horizontal)
                                }
                            }

                            Divider()

                            // 月別グラフ
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(selectedYear)年 月別売上")
                                    .font(.headline)
                                    .padding(.horizontal)

                                Chart(monthlyChartData, id: \.month) { data in
                                    BarMark(
                                        x: .value("月", "\(data.month)月"),
                                        y: .value("売上", data.total)
                                    )
                                    .foregroundStyle(.green)
                                }
                                .frame(height: 200)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                } else {
                    // 月合計カード
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(selectedYear)年\(selectedMonth)月の合計売上")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("¥\(Int(monthlyTotal).formatted())")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.green)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(.green.opacity(0.1))
                    .cornerRadius(12)
                    .padding()

                    // 週別リスト
                    List {
                        if filteredRecords.isEmpty {
                            Text("この月のデータがありません")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(filteredRecords.sorted { $0.week < $1.week }) { record in
                                HStack {
                                    Text("第\(record.week)週")
                                        .font(.headline)
                                    Spacer()
                                    Text("¥\(Int(record.amount).formatted())")
                                        .foregroundStyle(.green)
                                }
                            }
                            .onDelete(perform: deleteRecords)
                        }
                    }
                }
            }
            .navigationTitle("売上管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddSalesView()
            }
        }
    }

    private func deleteRecords(offsets: IndexSet) {
        let sorted = filteredRecords.sorted { $0.week < $1.week }
        for index in offsets {
            modelContext.delete(sorted[index])
        }
    }
}
