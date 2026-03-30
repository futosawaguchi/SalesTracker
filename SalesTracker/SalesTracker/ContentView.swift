//
//  ContentView.swift
//  SalesTracker
//
//  Created by 澤口楓斗 on 2026/03/30.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("ダッシュボード", systemImage: "house.fill")
                }

            SalesView()
                .tabItem {
                    Label("売上", systemImage: "yensign.circle.fill")
                }

            SNSView()
                .tabItem {
                    Label("Instagram", systemImage: "camera.fill")
                }

            ReviewView()
                .tabItem {
                    Label("口コミ", systemImage: "star.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            SalesRecord.self,
            SNSRecord.self,
            ReviewRecord.self
        ], inMemory: true)
}
