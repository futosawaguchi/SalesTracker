//
//  SNSView.swift
//  SalesTracker
//
//  Created by 澤口楓斗 on 2026/03/30.
//

import SwiftUI
import SwiftData

struct SNSView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SNSRecord.recordedAt, order: .reverse) private var records: [SNSRecord]

    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Instagram")
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
