//
//  SNSView.swift
//  SalesTracker
//
//  Created by 澤口楓斗 on 2026/03/30.
//

import SwiftUI
import SwiftData
import Charts

struct SNSView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SNSRecord.recordedAt, order: .reverse) private var records: [SNSRecord]

    @State private var showingAddSheet = false
    @State private var showChart = false
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())

    let years = Array(2020...2030)
    let months = Array(1...12)

    // 選択中の年月のレコードだけ抽出（古い順）
    var filteredRecords: [SNSRecord] {
        records.filter {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: $0.recordedAt)
            let month = calendar.component(.month, from: $0.recordedAt)
            return year == selectedYear && month == selectedMonth
        }.sorted { $0.recordedAt < $1.recordedAt }
    }

    // 選択中の月の日付範囲
    var monthDateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: selectedYear, month: selectedMonth, day: 1)
        let start = calendar.date(from: startComponents)!
        let end = calendar.date(byAdding: .month, value: 1, to: start)!
        return start...end
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // 年月セレクター（グラフ表示時のみ）
                if showChart {
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
                    }
                    .padding(.horizontal)
                }

                if showChart {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("\(selectedYear)年\(selectedMonth)月 フォロワー推移")
                                .font(.headline)
                                .padding(.horizontal)

                            if filteredRecords.isEmpty {
                                Text("この月のデータがありません")
                                    .foregroundStyle(.secondary)
                                    .padding()
                            } else {
                                Chart {
                                    ForEach(filteredRecords) { record in
                                        // フォロワー数（ピンク）
                                        LineMark(
                                            x: .value("日付", record.recordedAt, unit: .day),
                                            y: .value("人数", record.followers)
                                        )
                                        .foregroundStyle(by: .value("種別", "フォロワー"))
                                        .symbol(.circle)
                                        .interpolationMethod(.catmullRom)

                                        // フォロー中（青）
                                        LineMark(
                                            x: .value("日付", record.recordedAt, unit: .day),
                                            y: .value("人数", record.following)
                                        )
                                        .foregroundStyle(by: .value("種別", "フォロー中"))
                                        .symbol(.square)
                                        .interpolationMethod(.catmullRom)
                                    }
                                }
                                .chartXScale(domain: monthDateRange)
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day, count: 5)) { value in
                                        AxisGridLine()
                                        AxisTick()
                                        AxisValueLabel(format: .dateTime.day())
                                    }
                                }
                                .chartForegroundStyleScale([
                                    "フォロワー": Color.pink,
                                    "フォロー中": Color.blue
                                ])
                                .frame(height: 250)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                } else {
                    List {
                        if records.isEmpty {
                            Text("データがありません")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(records) { record in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(record.recordedAt, format: .dateTime.year().month().day())
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                    }
                                    HStack(spacing: 24) {
                                        VStack(alignment: .leading) {
                                            Text("フォロワー")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            Text("\(record.followers.formatted())")
                                                .font(.headline)
                                                .foregroundStyle(.pink)
                                        }
                                        VStack(alignment: .leading) {
                                            Text("フォロー中")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            Text("\(record.following.formatted())")
                                                .font(.headline)
                                                .foregroundStyle(.blue)
                                        }
                                        if !record.memo.isEmpty {
                                            VStack(alignment: .leading) {
                                                Text("メモ")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                Text(record.memo)
                                                    .font(.subheadline)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .onDelete(perform: deleteRecords)
                        }
                    }
                }
            }
            .navigationTitle("Instagram")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showChart.toggle() }) {
                        Image(systemName: showChart ? "list.bullet" : "chart.line.uptrend.xyaxis")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddSNSView()
            }
        }
    }

    private func deleteRecords(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(records[index])
        }
    }
}
