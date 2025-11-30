//
//  PredictionView.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import SwiftUI
import SwiftData

struct PredictionView: View {
    @Environment(\.modelContext) private var context
    @Binding var updatedRecently: Bool
    @Query(filter: predictionEventsPredicate()) private var predictionEvents: [Event]
    
    @State private var nextMenstrualEvent: Event = Event(date: Date())
    @State private var nextOvulationEvent: Event = Event(date: Date())
    
    // Helper to calculate next menstrual event
    private func calculateNextMenstrualEvent() -> Event {
        var minDays: TimeInterval = oneDay * 90
        var nextEvent = Event(date: Date())
        
        for event in predictionEvents where event.eventType == .menstrual {
            let dayDiff = event.date.startOfDay.timeIntervalSince1970 - Date().startOfDay.timeIntervalSince1970
            if dayDiff > 0 && dayDiff < minDays {
                nextEvent = event
                minDays = dayDiff
            }
        }
        return nextEvent
    }
    
    // Helper to calculate next ovulation event
    private func calculateNextOvulationEvent() -> Event {
        var minDays: TimeInterval = oneDay * 90
        var nextEvent = Event(date: Date())
        
        for event in predictionEvents where event.eventType == .ovulation {
            let dayDiff = event.date.startOfDay.timeIntervalSince1970 - Date().startOfDay.timeIntervalSince1970
            if dayDiff > 0 && dayDiff < minDays {
                nextEvent = event
                minDays = dayDiff
            }
        }
        return nextEvent
    }
    
    // Update predictions when data changes
    private func updatePredictions() {
        nextMenstrualEvent = calculateNextMenstrualEvent()
        nextOvulationEvent = calculateNextOvulationEvent()
    }
    
    // Helper function to format date string
    private func getMonthStr(event: Event) -> String {
        let months: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let monthIndex: Int = (event.dateComponents.month ?? 1) - 1
        return months[min(max(monthIndex, 0), 11)]
    }
    
    // Build text lines dynamically
    private var predictionLines: [String] {
        guard updatedRecently else {
            return ["Predictions not available", "Please update your data"]
        }
        
        let menstrualDate = "\(getMonthStr(event: nextMenstrualEvent)) \(nextMenstrualEvent.dateComponents.day ?? 0)"
        let ovulationDate = "\(getMonthStr(event: nextOvulationEvent)) \(nextOvulationEvent.dateComponents.day ?? 0)"
        
        return [
            "Next Menstrual:",
            menstrualDate,
            "Next Ovulation:",
            ovulationDate
        ]
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Next Menstrual:")
                .font(.system(size: 30))
            Text("\(getMonthStr(event: nextMenstrualEvent)) \(nextMenstrualEvent.dateComponents.day ?? 0)")
                .font(.system(size: 24))
            
            Text("Next Ovulation:")
                .font(.system(size: 30))
            Text("\(getMonthStr(event: nextOvulationEvent)) \(nextOvulationEvent.dateComponents.day ?? 0)")
                .font(.system(size: 24))
        }
        .padding(.vertical, 30)
        .onAppear {
            updatePredictions()
        }
        .onChange(of: updatedRecently) { _, newValue in
            if newValue {
                updatePredictions()
            }
        }
    }
}
