//
//  StatsListView.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import SwiftUI
import SwiftData

struct StatsListView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Binding var updatedRecently: Bool
    @Query private var events: [Event]
    @Query private var stats: [Stats]
    @Query(filter: predictionEventsPredicate()) private var predictedEvents: [Event]
    @Query(filter: durationPredicate()) private var durationStats: [Stats]
    @State private var prevDuration: TimeInterval = 0
    @State private var outliers: [Event:Int] = [:]
    
    func updateStat(newStat: Stats) -> Bool {
        var sortedStats: [Stats] = stats
        sortedStats.sort { $0.date < $1.date }
        
        for stat in sortedStats {
            if stat.type == newStat.type {
                if stat.value == newStat.value {
                    return false
                }
                else {
                    stat.value = newStat.value
                    return false
                }
            }
        }
        
        updatedRecently = true
        return true
    }
    
    func updateStatistics() {
        var realEvents: [Event] = []
        var durations: [Int] = []
        var avg: Double = 0
        var stdDev: Double = 0
        var typicalStartDate: Int = 0
        var newStat: Stats = Stats(date: Date(), value: 0, type: "")
        
        if events.count < 2 {
            return
        }
        
        for event in events {
            if !event.prediction {
                realEvents.append(event)
            }
        }
        
        realEvents = getCycleStartDate(events: events)
        
        durations = getDurations(events: events)
        avg = getAvgDuration(events: realEvents, durations: durations)
        stdDev = getStdDev(items: durations, avg: avg)
        typicalStartDate = getTypicalStartDate(events: realEvents)
        newStat = Stats(date: Date(), value: avg, type: "menstrual-duration")
        if updateStat(newStat: newStat) {
            context.insert(newStat)
        }
        avg = 0
        for cycle in getCycleEvents(events: events) {
            durations = getDurations(events: cycle)
            avg += getAvgDuration(events: cycle, durations: durations)
            avg /= 2
        }
        newStat = Stats(date: Date(), value: avg, type: "menstrual-timeBetween")
        if updateStat(newStat: newStat) {
            context.insert(newStat)
        }
        newStat = Stats(date: Date(), value: stdDev, type: "menstrual-stdDev")
        if updateStat(newStat: newStat) {
            context.insert(newStat)
        }
        newStat = Stats(date: Date(), value: Double(typicalStartDate), type: "menstrual-typicalStartDate")
        if updateStat(newStat: newStat) {
            context.insert(newStat)
        }
        newStat = Stats(date: Date(), value: Double(outliers.count), type: "menstrual-outlierCount")
        if updateStat(newStat: newStat) {
            context.insert(newStat)
        }
        
        newStat = Stats(date: Date(), value: Double(getAvgTypeAsDouble(allevents: events, enumType: EnumType.flow)), type: "menstrual-avgFlow")
        if updateStat(newStat: newStat) {
            context.insert(newStat)
        }
        newStat = Stats(date: Date(), value: Double(getAvgTypeAsDouble(allevents: events, enumType: EnumType.clotting)), type: "menstrual-avgClotting")
        if updateStat(newStat: newStat) {
            context.insert(newStat)
        }
        newStat = Stats(date: Date(), value: Double(getAvgTypeAsDouble(allevents: events, enumType: EnumType.spotting)), type: "menstrual-avgSpotting")
        if updateStat(newStat: newStat) {
            context.insert(newStat)
        }
        newStat = Stats(date: Date(), value: Double(getAvgTypeAsDouble(allevents: events, enumType: EnumType.energy)), type: "menstrual-avgEnergy")
        if updateStat(newStat: newStat) {
            context.insert(newStat)
        }
        newStat = Stats(date: Date(), value: Double(getAvgTypeAsDouble(allevents: events, enumType: EnumType.feeling)), type: "menstrual-avgFeeling")
        if updateStat(newStat: newStat) {
            context.insert(newStat)
        }
        newStat = Stats(date: Date(), value: Double(getAvgTypeAsDouble(allevents: events, enumType: EnumType.pain)), type: "menstrual-avgPain")
        if updateStat(newStat: newStat) {
            context.insert(newStat)
        }
        
    }
    
    var body: some View {
        NavigationStack {
            List {
                VStack (alignment: .leading) {
                    ForEach(stats.sorted {$0.date < $1.date}) { stat in
                        if stat.type.contains("menstrual")
                        {
                            if !stat.type.contains("outlier") && !stat.type.contains("stdDev") {
                                StatsViewRow(stat: stat, index: stat.type.firstIndex(of: "-")!)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Statistics")
            .onAppear(){
                if events.count > 0 {
                    updateStatistics()
                    (prevDuration, outliers) = updatePrediction(events: events, i_predictionEvents: predictedEvents)
                    
                    // Check for new outliers and add them to the stats
                    for stat in stats {
                        if (stat.type == "menstrual-outlierCount") && (Int(stat.value) < outliers.count) {
                            for stat in stats {
                                // Remove old outliers
                                if stat.type.contains("outlier") {
                                    context.delete(stat)
                                }
                            }
                            var newStat: Stats = Stats(date: Date(), value: Double(outliers.count), type: "menstrual-outlierCount")
                            context.insert(newStat)
                            var count: Int = 0
                            for outlier in outliers.keys {
                                newStat = Stats(date: outlier.date, value: Double(outliers[outlier]!), type: "menstrual-outlier\(count)")
                                count += 1
                            }
                        }
                    }
                }
            }
            Button {
                dismiss()
            } label: {
                Text("Close").font(.system(size: 20))
            }
        }
    }
}

