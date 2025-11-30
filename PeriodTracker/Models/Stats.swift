//
//  Stats.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import SwiftData
import Foundation
import os

func createPredictionEvents() -> [Event] {
    let numPredictionEvents: Int = 4
    var predictionEvents: [Event] = []
    
    // create prediction events
    for i in 0...numPredictionEvents {
        for j in 0...1 {
            let newEvent = Event(date: Date() - (oneDay * 365) + (TimeInterval(i)*oneDay),
                                 prediction: true)
            
            // Create menstrual predictions
            if j == 1 {
                newEvent.eventType = EventType.menstrual
            }
            // Create ovulation predictions
            else {
                newEvent.eventType = EventType.ovulation
            }
            predictionEvents.append(newEvent)
        }
    }
    return predictionEvents
}

func quicksortEvents(events: [Event]) -> [Event] {
    guard events.count > 1 else { return events }

    let pivot = events[events.count/2].date.startOfDay.timeIntervalSince1970
    let less = events.filter { $0.date.startOfDay.timeIntervalSince1970 < pivot }
    let equal = events.filter { $0.date.startOfDay.timeIntervalSince1970 == pivot }
    let greater = events.filter { $0.date.startOfDay.timeIntervalSince1970 > pivot }

    return quicksortEvents(events:less) + equal + quicksortEvents(events: greater)
}

func getAvgType(allevents:[Event], enumType: EnumType) -> String {
    let logger = Logger(subsystem: "Stats", category: "getAvgType")
    var relevantEvents: [Event] = []
    var typeCounts: [String: Int] = [:]
    var avgType: String = "none"
    var avgCount: Int = 0
    
    // Grab the relevant events
    for event in allevents {
        if !event.prediction {
            switch enumType {
            case .flow:
                if event.flowType != FlowType.none {
                    relevantEvents.append(event)
                }
                break
            case .spotting:
                for spotting in event.spottingType {
                    if spotting != SpottingType.none {
                        relevantEvents.append(event)
                    }
                }
                break
            case .clotting:
                if event.clottingType != ClottingType.none {
                    relevantEvents.append(event)
                }
                break
            case .energy:
                if event.energyType != EnergyType.none {
                    relevantEvents.append(event)
                }
                break
            case .feeling:
                for feeling in event.feelingType {
                    if feeling != FeelingType.none {
                        relevantEvents.append(event)
                    }
                }
                break
            case .pain  :
                if event.painType != PainType.none {
                    relevantEvents.append(event)
                }
                break
            }
        }
    }
    
    // If there are none, exit
    if relevantEvents.count == 0 {
        return avgType
    }
    
    logger.debug("Enum Type: \(enumType.rawValue) Num events: \(relevantEvents.count)")
    
    // Set the enum types in the dictionary
    switch enumType {
    case .flow:
        for type in FlowType.allCases {
            if type == FlowType.none { continue }
            typeCounts[type.rawValue] = 0
        }
        break
    case .spotting:
        for type in SpottingType.allCases {
            if type == SpottingType.none { continue }
            typeCounts[type.rawValue] = 0
        }
        break
    case .clotting:
        for type in ClottingType.allCases {
            if type == ClottingType.none { continue }
            typeCounts[type.rawValue] = 0
        }
        break
    case .energy:
        for type in EnergyType.allCases {
            if type == EnergyType.none { continue }
            typeCounts[type.rawValue] = 0
        }
        break
    case .feeling:
        for type in FeelingType.allCases {
            if type == FeelingType.none { continue }
            typeCounts[type.rawValue] = 0
        }
        break
    case .pain  :
        for type in PainType.allCases {
            if type == PainType.none { continue }
            typeCounts[type.rawValue] = 0
        }
        break
    }
    
    logger.debug("Enum Types: \(typeCounts.keys)")
    
    // Count the types
    for event in relevantEvents {
        switch enumType {
        case .flow:
            typeCounts[event.flowType.rawValue]! += 1
            break
        case .spotting:
            for spotting in event.spottingType {
                typeCounts[spotting.rawValue]! += 1
            }
            break
        case .clotting:
            typeCounts[event.clottingType.rawValue]! += 1
            break
        case .energy:
            typeCounts[event.energyType.rawValue]! += 1
            break
        case .feeling:
            for feeling in event.feelingType {
                typeCounts[feeling.rawValue]! += 1                
            }
            break
        case .pain  :
            typeCounts[event.painType.rawValue]! += 1
            break
        }
    }
    
    // Final average count
    for key in typeCounts.keys {
        logger.debug("Type (\(key)) Count: \(typeCounts.values)")
        if typeCounts[key]! > avgCount {
            avgCount = typeCounts[key]!
            avgType = key
        }
    }
    
    return avgType
}

func getAvgTypeAsDouble(allevents:[Event], enumType: EnumType) -> Double {
    let typeAsString = getAvgType(allevents: allevents, enumType: enumType)
    
    if typeAsString == "flow" {
        return 0
    }
    else if typeAsString == "spotting" {
        return 1
    }
    else if typeAsString == "clotting" {
        return 2
    }
    else if typeAsString == "feeling" {
        return 3
    }
    else if typeAsString == "pain" {
        return 4
    }
    else if typeAsString == "energy" {
        return 5
    }
    
    return 99
}

func getCycleEvents(events: [Event]) -> [[Event]] {
    var cycleEvents: [[Event]] = [[]]
    var currCycle: [Event] = []
    
    cycleEvents.removeAll()
    currCycle.append(events[0])
    for i in 1...events.count-1 {
        if events[i].prediction {
            continue
        }
        let dayDiff = (events[i].date.startOfDay.timeIntervalSince1970 - events[i-1].date.startOfDay.timeIntervalSince1970)
        if dayDiff < comparisonTime {
            currCycle.append(events[i])
        }
        else if dayDiff > 0 {
            cycleEvents.append(currCycle)
            currCycle.removeAll()
            currCycle.append(events[i])
        }
    }
    
    if currCycle.count > 0 {
        cycleEvents.append(currCycle)
    }
    
    return cycleEvents
}

func getCycleStartDate(events: [Event]) -> [Event]{
    var startEvents: [Event] = []
    if events.count < 2 {
        return startEvents
    }
    
    if !events[0].prediction {
        startEvents.append(events[0])
    }
    for i in 1...events.count-1 {
        if events[i].prediction {
            continue
        }
        else if events[i-1].prediction {
            startEvents.append(events[i])
            continue
        }
        let dayDiff = (events[i].date.startOfDay.timeIntervalSince1970 - events[i-1].date.startOfDay.timeIntervalSince1970)
        // get the delta if the events are more than a week apart, assuming separate cycles
        if (dayDiff > comparisonTime) {
            startEvents.append(events[i])
        }
    }
    
    return startEvents
}

func getDeltaInDays(firstEvent: Event, secondEvent: Event) -> Int {
    var deltaTimeInterval: TimeInterval = 0
    var deltaDays: Int = 0
    deltaTimeInterval = firstEvent.date.startOfDay.timeIntervalSince1970 - secondEvent.date.startOfDay.timeIntervalSince1970
    deltaDays = Int(deltaTimeInterval / oneDay)
    return deltaDays
}

// Assumes events are sorted by date when passed in
func getDurations(events: [Event]) -> [Int] {
    var deltas: [Int] = []
    
    if events.count < 2 {
        return [0]
    }

    for i in 1...events.count-1 {
        deltas.append(getDeltaInDays(firstEvent: events[i], secondEvent: events[i-1]))
    }
    
    return deltas
}

func getStdDev(items: [Int],  avg: Double) -> Double {
    var stddev: Double = 0
    
    if items.count < 3 {
        return 0
    }
    
    for i in 0...items.count-1 {
        stddev += pow(Double(items[i] - Int(avg)), 2)
    }
    stddev = sqrt(stddev/Double(items.count))
    
    return stddev
}

// Get the average length of time of a period lasts (in days)
func getAvgCycleDuration(events: [Event]) -> Double {
    let logger = Logger(subsystem: "Stats", category: "getAvgCycleDuration")
    var average: Double = 0
    var cycleEvents: [[Event]] = [[]]
    
    if events.count < 4 {
        return 0
    }
    
    cycleEvents = getCycleEvents(events: events.sorted(by: {$0.date.startOfDay.timeIntervalSince1970 < $1.date.startOfDay.timeIntervalSince1970}))
    
    for cycle in cycleEvents {
        average += Double(cycle.count)
    }
    
    average /= Double(cycleEvents.count)
    
    logger.debug("Avg Cycle Duration: \(average)")
    
    return average
}

func getAvgDuration(events: [Event], durations: [Int]) -> Double {
    let logger = Logger(subsystem: "Stats", category: "getAvgDuration")
    let today: Event = Event(date: Date())
    var average: Double = 0
    var count: Int = 0
    
    if events.count < 2 || durations.count < 2 {
        if durations.count > 0 {
            average = Double(durations[0])
        }
        return average
    }
    
    if events.count < durations.count {
        count = events.count
    }
    else {
        count = durations.count
    }
    
    // Take the biased (towards more recent events) average
    // Most recent duration is take at 100% confidence/bias
    average = Double(durations[count-1])
    for i in 0...(count-2) {
        average += Double(durations[i])
        average /= 2
        // Dates within the last ~4 months have a 100% confidence
        // dates within the last year have a higher weight than those further back
        var modifier: Double = Double(getDeltaInDays(firstEvent: today, secondEvent: events[i]))
        if modifier > 365 {
            modifier = pow((modifier / 365) + 1, -1)
            average *= modifier
        }
    }
    
    logger.debug("Avg Duration: \(average)")
    
    return average
}

// Events expects correct length of data and sorted to be presented
// Can be all data, or a partial segement
func getTypicalStartDate(events: [Event]) -> Int {
    if events.count < 3 {
        return 0
    }
    
    // Weight is expected that the further back the date is, the less impact it
    let weight: Double = Double(events.count) / (Double(events.count) * 10)
    var relevantEvents: [Event] = []
    var startDates: [Double] = []
    var startDateCount: Double = 0
    var typicalStartDate: Int = 1
    
    
    for _ in 0...31 {
        startDates.append(0)
    }
    
    for event in events {
        if !event.prediction{
            relevantEvents.append(event)
        }
    }
    
    
    for i in 0...relevantEvents.count-1 {
        startDates[relevantEvents[i].dateComponents.day!] += 1 * ((Double(i)+1) * weight)
    }
    
    for i in 1...startDates.count-1 {
        if startDates[i] > startDateCount {
            typicalStartDate = i
            startDateCount = startDates[i]
        }
    }
    
    return typicalStartDate
}

// Events expects correct length of data and sorted to be presented
// Can be all data, or a partial segement
func getCycleVariations(events: [Event]) -> [Event: Int] {
    
    // Calc the z-score
    var averages: [Double] = []
    var stddev: Double = 0.0
    var zscore: Int = 0
    var outliers: [Event:Int] = [:]
    var durations: [Int] = []
    var cycleEvents: [[Event]] = [[]]
    
    // Not enough events to start taking statistics
    if events.count <= 4 {
        return [:]
    }

    cycleEvents = getCycleEvents(events: events)
    
    if cycleEvents.count < 2 {
        return [:]
    }
    
    // Second get variations within cycles
    for i in 0...cycleEvents.count-1 {
        durations = getDurations(events: cycleEvents[i])
        
        // If there's a discrepncy between the lengths of the arrays
        if durations.count != events.count/2 {
            break
        }
        averages.append(Double(cycleEvents[i].count))
                
    }
    
    for average in averages {
        stddev = getStdDev(items: durations, avg: average)
        
        if stddev == 0 {
            continue
        }
        
        for i in 0...durations.count-1 {
            if Double(durations[i]) == average {
                continue
            }
            zscore = Int((Double(durations[i]) - average) / stddev)
            if abs(zscore) > 3 {
                outliers[events[i*2]] = zscore
            }
        }
    }
    
    return outliers
}

// Events expects correct length of data and sorted to be presented
// Can be all data, or a partial segement
func getVariationsBetweenCycles(events: [Event]) -> [Event: Int] {
    
    // Calc the z-score
    var average: Double = 0
    var stddev: Double = 0.0
    var zscore: Int = 0
    var outliers: [Event:Int] = [:]
    var durations: [Int] = []
    var startEvents: [Event] = []
    
    // Not enough events to start taking statistics
    if events.count <= 4 {
        return [:]
    }

    startEvents = getCycleStartDate(events: events)
    
    durations = getDurations(events: startEvents)
    
    // If there's a discrepncy between the lengths of the arrays
    if durations.count != events.count/2 {
        return [:]
    }
    
    average = getAvgDuration(events: startEvents, durations: durations)
    
    stddev = getStdDev(items: durations, avg: average)
    
    if stddev == 0 {
        return [:]
    }
        
    for i in 0...durations.count-1 {
        if Double(durations[i]) == average {
            continue
        }
        zscore = Int((Double(durations[i]) - average) / stddev)
        if abs(zscore) > 3 {
            outliers[events[i*2]] = zscore
        }
    }
    
    return outliers
}

// Sets prevDurations 
func setPrevDurations(events:[Event]) -> (TimeInterval, [Event: Int]) {
    let logger = Logger(subsystem: "Stats", category: "setPrevDurations")
    var durations: [Int] = []
    var avgDuration:TimeInterval = 0
    
    if events.count < 2 {
        return (avgDuration, [:])
    }
    
    var avgInDays: Double = 0
    var outliers: [Event: Int] = [:]
    var allOutliers: [Event: Int] = [:]
    
    durations = getDurations(events: events)
    avgInDays = getAvgDuration(events: events, durations: durations)
    avgDuration = TimeInterval(avgInDays)
    outliers = getVariationsBetweenCycles(events: events)
    allOutliers = outliers
    if outliers.count > 0 {
        logger.debug("Outliers between cycles: ")
        for outlier in outliers.keys {
            logger.debug("\(outlier.date) \(outliers[outlier]!)")
        }
    }
    
    outliers = getCycleVariations(events: events)
    for outlier in outliers {
        allOutliers[outlier.key] = outlier.value
    }
    if outliers.count > 0 {
        logger.debug("Cycle Variations: ")
        for outlier in outliers.keys {
            logger.debug("\(outlier.date) \(outliers[outlier]!)")
        }
    }
    return (avgDuration, allOutliers)
}

func updatePrediction(events: [Event], i_predictionEvents: [Event]) -> (TimeInterval, [Event:Int]) {
    let logger = Logger(subsystem: "Stats", category: "updatePredictions")
    var sortedEvents: [Event] = []
    var startEvents: [Event] = []
    var predictionEvents: [Event] = i_predictionEvents.sorted(by: {$0.date.startOfDay.timeIntervalSince1970 < $1.date.startOfDay.timeIntervalSince1970})
    var avgTimeBetween: TimeInterval = 0
    var prevEvent: Event = Event(date: Date())
    var outliers: [Event: Int] = [:]
    let cycleAvg: Double = getAvgCycleDuration(events: events)
    
    if (events.count - i_predictionEvents.count) < 3{
        return (0, [:])
    }
    
    if i_predictionEvents.count == 0 {
        predictionEvents = createPredictionEvents().sorted(by: {$0.date.startOfDay.timeIntervalSince1970 < $1.date.startOfDay.timeIntervalSince1970})
    }
    
    for event in events {
        if !event.prediction && event.eventType == EventType.menstrual {
            sortedEvents.append(event)
        }
    }
    sortedEvents = quicksortEvents(events: sortedEvents)
    
    startEvents = getCycleStartDate(events: sortedEvents)
    if startEvents.isEmpty {
        return (0, [:])
    }
        
    prevEvent = startEvents.last!
    
    // Set the predictions based on the current events
    (avgTimeBetween, outliers) = setPrevDurations(events: startEvents)
    // Include length of a period + the full cycle
    avgTimeBetween -= cycleAvg
    logger.debug("Average duration to be used in predcitions: \(avgTimeBetween)")
    logger.debug("Most recent event \(prevEvent.date)")
    for i in 0...predictionEvents.count-1 {
        if prevEvent.eventType == predictionEvents[i].eventType {
            if predictionEvents[i].eventType == EventType.ovulation {
                predictionEvents[i].eventType = EventType.menstrual
            }
            else {
                predictionEvents[i].eventType = EventType.ovulation
            }
        }
        
        if predictionEvents[i].eventType == EventType.menstrual {
            // Set current prediction event's date to duration * the current number of the prediction
            predictionEvents[i].date = prevEvent.date.startOfDay + (avgTimeBetween * oneDay)
            prevEvent = predictionEvents[i]
        }
        else {
            // Set current prediction event's date to duration * the current number of the prediction
            predictionEvents[i].date = prevEvent.date.startOfDay + ((avgTimeBetween/3) * oneDay)
            prevEvent = predictionEvents[i]
        }
        logger.debug("Prediction event update: \(predictionEvents[i].date) \(predictionEvents[i].eventType.rawValue)")
    }
    
    return (avgTimeBetween, outliers)
}

enum StatsSchemaV1: VersionedSchema {
    
    static var versionIdentifier = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [Stats.self]
    }
    
    @Model
    final class Stats {
        var date: Date
        var value: Double
        var type: String
        
        init(date: Date, value: Double, type: String) {
            self.date = date
            self.value = value
            self.type = type
        }
    }
}

typealias Stats = StatsSchemaV1.Stats
