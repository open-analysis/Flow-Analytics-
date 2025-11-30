//
//  SettingsView.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import SwiftUI

struct SettingsView: View {
    
    var body: some View {
        VStack {
            Text("Settings").font(.title)
            TabView {
                SettingsCalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                SettingsNotificationsView()
                    .tabItem {
                        Label("Notifications", systemImage: "message")
                    }
                SettingsFeedbackView()
                    .tabItem {
                        Label("Feedback", systemImage: "text.bubble")
                    }
            }
        }
    }
}
