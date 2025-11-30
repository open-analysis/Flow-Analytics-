//
//  PeriodTrackerApp.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import SwiftUI
import SwiftData

@main
struct PeriodTrackerApp: App {
    @State var updatedRecently: Bool = true
    
    var body: some Scene {
        WindowGroup {
            EventsCalendarView(updatedRecently: $updatedRecently)
                .modelContainer(for: [
                    Event.self,
                    Stats.self
                ])
        }
    }
}
