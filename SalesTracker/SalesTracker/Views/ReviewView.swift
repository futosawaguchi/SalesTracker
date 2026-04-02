//
//  ReviewView.swift
//  SalesTracker
//
//  Created by 澤口楓斗 on 2026/03/30.
//

import SwiftUI
import SwiftData
import Charts

struct ReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ReviewRecord.recordedAt, order: .reverse) private var records: [ReviewRecord]

    @State private var showingAddSheet = false
    @State private var showChart = false
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())

    let years = Array(2020...2030)
    let months = Array(1...12)

    var filteredRecords: [ReviewRecord] {
        records.filter {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: $0.recordedAt)
            let month = calendar.component(.month, from: $0.recordedAt)
            return year == selectedYear && month == selectedMonth
        }.sorted { $0.recordedAt < $1.recordedAt }
    }

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

                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("\(selectedYear)年\(selectedMonth)月 口コミ数推移")
                                .font(.headline)
                                .padding(.horizontal)

                            if filteredRecords.isEmpty {
                                Text("この月のデータがありません")
                                    .foregroundStyle(.secondary)
                                    .padding()
                            } else {
                                Chart {
                                    ForEach(filteredRecords) { record in
                                        LineMark(
                                            x: .value("日付", record.recordedAt, unit: .day),
                                            y: .value("口コミ数", record.count)
                                        )
                                        .foregroundStyle(.orange)
                                        .symbol(.circle)
                                        .interpolationMethod(.catmullRom)

                                        AreaMark(
                                            x: .value("日付", record.recordedAt, unit: .day),
                                            y: .value("口コミ数", record.count)
                                        )
                                        .foregroundStyle(.orange.opacity(0.1))
                                        .interpolationMethod(.catmullRom)
                                    }
                                }
                                .chartXScale(domain: monthDateRange)
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day, count: 5)) { _ in
                                        AxisGridLine()
                                        AxisTick()
                                        AxisValueLabel(format: .dateTime.day())
                                    }
                                }
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
                                    Text(record.recordedAt, format: .dateTime.year().month().day())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("口コミ数")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            Text("\(record.count)件")
                                                .font(.headline)
                                                .foregroundStyle(.orange)
                                        }
                                        if !record.memo.isEmpty {
                                            Spacer()
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
            .navigationTitle("口コミ管理")
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
                AddReviewView()
            }
        }
    }

    private func deleteRecords(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(records[index])
        }
    }
}
