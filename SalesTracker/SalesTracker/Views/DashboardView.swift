//
//  DashboardView.swift
//  SalesTracker
//
//  Created by 澤口楓斗 on 2026/03/30.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var salesRecords: [SalesRecord]
    @Query private var snsRecords: [SNSRecord]
    @Query private var reviewRecords: [ReviewRecord]

    let calendar = Calendar.current

    // 現在の年月
    var currentYear: Int { calendar.component(.year, from: Date()) }
    var currentMonth: Int { calendar.component(.month, from: Date()) }

    // 先月の年月
    var lastMonthDate: Date {
        calendar.date(byAdding: .month, value: -1, to: Date())!
    }
    var lastMonthYear: Int { calendar.component(.year, from: lastMonthDate) }
    var lastMonthMonth: Int { calendar.component(.month, from: lastMonthDate) }

    // ── 売上 ──
    var thisMonthSales: Double {
        salesRecords
            .filter { $0.year == currentYear && $0.month == currentMonth }
            .reduce(0) { $0 + $1.amount }
    }
    var lastMonthSales: Double {
        salesRecords
            .filter { $0.year == lastMonthYear && $0.month == lastMonthMonth }
            .reduce(0) { $0 + $1.amount }
    }
    var salesDiff: Double { thisMonthSales - lastMonthSales }

    // ── Instagram ──
    var latestSNS: SNSRecord? {
        snsRecords.sorted { $0.recordedAt > $1.recordedAt }.first
    }
    var firstThisMonthSNS: SNSRecord? {
        snsRecords
            .filter {
                calendar.component(.year, from: $0.recordedAt) == currentYear &&
                calendar.component(.month, from: $0.recordedAt) == currentMonth
            }
            .sorted { $0.recordedAt < $1.recordedAt }
            .first
    }
    var followersDiff: Int {
        guard let latest = latestSNS, let first = firstThisMonthSNS else { return 0 }
        return latest.followers - first.followers
    }

    // ── 口コミ ──
    var latestReview: ReviewRecord? {
        reviewRecords.sorted { $0.recordedAt > $1.recordedAt }.first
    }
    var firstThisMonthReview: ReviewRecord? {
        reviewRecords
            .filter {
                calendar.component(.year, from: $0.recordedAt) == currentYear &&
                calendar.component(.month, from: $0.recordedAt) == currentMonth
            }
            .sorted { $0.recordedAt < $1.recordedAt }
            .first
    }
    var reviewDiff: Int {
        guard let latest = latestReview, let first = firstThisMonthReview else { return 0 }
        return latest.count - first.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // 売上カード
                    DashboardCard(
                        title: "今月の売上",
                        icon: "yensign.circle.fill",
                        iconColor: .green,
                        mainValue: "¥\(Int(thisMonthSales).formatted())",
                        diffValue: salesDiff == 0 ? nil : (salesDiff > 0 ? "+¥\(Int(salesDiff).formatted())" : "-¥\(Int(abs(salesDiff)).formatted())"),
                        isPositive: salesDiff >= 0,
                        subText: "先月比"
                    )

                    // Instagramカード
                    DashboardCard(
                        title: "Instagram フォロワー",
                        icon: "camera.fill",
                        iconColor: .pink,
                        mainValue: latestSNS.map { "\($0.followers.formatted())人" } ?? "未記録",
                        diffValue: followersDiff == 0 ? nil : (followersDiff > 0 ? "+\(followersDiff)人" : "\(followersDiff)人"),
                        isPositive: followersDiff >= 0,
                        subText: "今月の増減"
                    )

                    // 口コミカード
                    DashboardCard(
                        title: "Google Maps 口コミ",
                        icon: "star.fill",
                        iconColor: .orange,
                        mainValue: latestReview.map { "\($0.count)件" } ?? "未記録",
                        diffValue: reviewDiff == 0 ? nil : (reviewDiff > 0 ? "+\(reviewDiff)件" : "\(reviewDiff)件"),
                        isPositive: reviewDiff >= 0,
                        subText: "今月の増減"
                    )
                }
                .padding()
            }
            .navigationTitle("ダッシュボード")
        }
    }
}

// カードコンポーネント
struct DashboardCard: View {
    let title: String
    let icon: String
    let iconColor: Color
    let mainValue: String
    let diffValue: String?
    let isPositive: Bool
    let subText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // タイトル行
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
            }

            // メイン数値
            Text(mainValue)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(iconColor)

            // 増減表示
            if let diff = diffValue {
                HStack(spacing: 4) {
                    Image(systemName: isPositive ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .foregroundStyle(isPositive ? .green : .red)
                    Text(subText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(diff)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(isPositive ? .green : .red)
                }
            } else {
                Text("増減データなし")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(iconColor.opacity(0.08))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(iconColor.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [
            SalesRecord.self,
            SNSRecord.self,
            ReviewRecord.self
        ], inMemory: true)
}
