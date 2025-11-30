//
//  CalendarView.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import SwiftUI
import SwiftData

struct CalendarView: UIViewRepresentable {
    let interval: DateInterval
    @Binding var dateSelected: DateComponents?
    @Binding var displayEvents: Bool
    @Binding var updatedRecently: Bool
    @Environment(\.modelContext) private var context
    @Query private var events: [Event]
    @Query private var allStats: [Stats]
    @Query(filter: predictionEventsPredicate()) private var predictedEvents: [Event]
    @Query(filter: durationPredicate()) private var durationStats: [Stats]
    
    func firstRun() {
        // This function inserts initial Stats and prediction events.
        // It must not be called synchronously during makeUIView (doing so can cause re-entrant @Query updates).
        let eventTypes = ["menstrual", "follicular", "ovulation", "luteal"]
        let statTypes = ["duration", "timeBetween", "typicalStartDate", "stdDev"]
        
        for statType in statTypes {
            for eventType in eventTypes {
                context.insert(Stats.init(date: Date(), value: 0, type: "\(eventType)-\(statType)"))
            }
        }
        
        context.insert(Stats.init(date: Date(), value: 0, type: "menstrual-avgFlow"))
        context.insert(Stats.init(date: Date(), value: 0, type: "menstrual-avgClotting"))
        context.insert(Stats.init(date: Date(), value: 0, type: "menstrual-avgSpotting"))
        context.insert(Stats.init(date: Date(), value: 0, type: "menstrual-avgEnergy"))
        context.insert(Stats.init(date: Date(), value: 0, type: "menstrual-avgFeeling"))
        context.insert(Stats.init(date: Date(), value: 0, type: "menstrual-avgPain"))
        
        let predictionEvents = createPredictionEvents()
        for event in predictionEvents {
            context.insert(event)
        }
    }

    func makeUIView(context: Context) -> UICalendarView {
        // If this is the first time (no duration stats yet), schedule firstRun asynchronously
        // so we don't perform SwiftData writes while the view is being constructed.
        if durationStats.count == 0 || predictedEvents.count == 0{
            DispatchQueue.main.async {
                // Double-check (might have been populated meanwhile)
                if durationStats.count == 0 {
                    firstRun()
                }
            }
        }
        
        let view = UICalendarView()
        view.delegate = context.coordinator
        view.calendar = Calendar(identifier: .gregorian)
        view.availableDateRange = interval
        let dateSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.selectionBehavior = dateSelection
        return view
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, events: events, predictedEvents: predictedEvents, durationStats: durationStats, updatedRecently: updatedRecently, modelContext: context)
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        // Update coordinator with latest query data. Coordinator will compute stats in-memory
        // and schedule persistence via the debounced persister (no immediate writes on render path).
        
        if !updatedRecently {
            return
        }
        
        let eventsChanged = events.count != context.coordinator.events.count
            || predictedEvents.count != context.coordinator.predictedEvents.count
            || durationStats.count != context.coordinator.durationStats.count
        
        context.coordinator.updateData(events: events,
                                       predictedEvents: predictedEvents,
                                       durationStats: durationStats,
                                       updatedRecentlyFlag: updatedRecently,
                                       calendarView: uiView,
                                       eventsChanged: eventsChanged)
        
        // Reset the binding (caller sets it when user action occurs)
        updatedRecently = false
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: CalendarView
        // keep local copies so the UICalendarView delegate uses the latest data
        var events: [Event]
        var predictedEvents: [Event]
        var durationStats: [Stats]
        // This local flag is used to guard one-time in-delegate updates; persistence is debounced.
        var updatedRecently: Bool
        private var outliers: [Event:Int] = [:]
        private var modelContext: ModelContext
        let defaults = UserDefaults.standard
        
        init(parent: CalendarView, events: [Event], predictedEvents: [Event], durationStats: [Stats], updatedRecently: Bool, modelContext: ModelContext) {
            self.parent = parent
            self.events = events
            self.predictedEvents = predictedEvents
            self.durationStats = durationStats
            self.updatedRecently = updatedRecently
            self.modelContext = modelContext
        }
        
        // Called from updateUIView so coordinator can refresh cached arrays, compute stats (in-memory),
        // and schedule safe persistence via StatsPersister. Avoid direct writes here.
        @MainActor
        func updateData(events: [Event],
                        predictedEvents: [Event],
                        durationStats: [Stats],
                        updatedRecentlyFlag: Bool,
                        calendarView: UICalendarView,
                        eventsChanged: Bool) {
            // Update cached arrays used for drawing decorations
            self.events = events
            self.predictedEvents = predictedEvents
            self.durationStats = durationStats
            self.updatedRecently = updatedRecentlyFlag
            
            // Prepare the dates to reload
            var dateComponentsToReload: [DateComponents] = []
            if eventsChanged {
                for event in self.events {
                    dateComponentsToReload.append(event.dateComponents)
                }
                for pred in self.predictedEvents {
                    dateComponentsToReload.append(pred.dateComponents)
                }
            }
            if dateComponentsToReload.isEmpty {
                dateComponentsToReload.append(Calendar.current.dateComponents([.year, .month, .day], from: Date()))
            }
            calendarView.reloadDecorations(forDateComponents: dateComponentsToReload, animated: true)
            
            // If a user action requested updates, compute statistics in-memory and schedule safe persistence.
            // We do the expensive/potentially-mutating work outside the decoration path and via the debouncer.
            if updatedRecentlyFlag {
                // Compute new prevDurations and outliers in-memory (no writes)
                var statDuration: Double = 0
                for stat in durationStats {
                    if stat.type == "menstrual-duration" {
                        statDuration = stat.value
                        break
                    }
                }
                let (newStatDuration, newOutliers) = updatePrediction(events: events, i_predictionEvents: predictedEvents)
                statDuration = newStatDuration
                // Schedule debounced persistence of these results — StatsPersister will perform writes off the render path.
                StatsPersister.shared.schedulePersist(prevDuration: statDuration, outliers: newOutliers, durationStats: durationStats, modelContext: self.modelContext)
            }
        }
        
        func initLabel(event: Event?) -> UILabel {
            let icon = UILabel()
            let defaults = UserDefaults.standard
            var eventIcon: String = "😶‍🌫️"
            var eventUIColor: UIColor = UIColor(.purple)
            var predictionUIColor: UIColor = (.magenta)
            var arr: [CGFloat] = []
            
            if event == nil {
                icon.text = "\t\t"
                icon.backgroundColor = UIColor(.clear)
            }
            else {
                if event!.eventType == EventType.menstrual {
                    eventIcon = defaults.string(forKey: "menstrualIcon") ?? "🎃"
                    arr = (defaults.array(forKey: "menstrualColor") as? [CGFloat] ?? Color("menstrual").toRGB())!
                    eventUIColor = UIColor(red: arr[0], green: arr[1], blue: arr[2], a: arr[3])
                    arr = (defaults.array(forKey: "predictionMenstrualColor") as? [CGFloat] ?? Color("paleMenstrual").toRGB())!
                    predictionUIColor = UIColor(red: arr[0], green: arr[1], blue: arr[2], a: arr[3])
                }
                else if event!.eventType == EventType.ovulation {
                    eventIcon = defaults.string(forKey: "ovulationIcon") ?? "🪺"
                    arr = (defaults.array(forKey: "ovulationColor") as? [CGFloat] ?? Color("ovulation").toRGB())!
                    eventUIColor = UIColor(red: arr[0], green: arr[1], blue: arr[2], a: arr[3])
                    arr = (defaults.array(forKey: "predictionOvulationColor") as? [CGFloat] ?? Color("paleOvulation").toRGB())!
                    predictionUIColor = UIColor(red: arr[0], green: arr[1], blue: arr[2], a: arr[3])
                }
                else if event!.eventType == EventType.informative {
                    eventIcon = defaults.string(forKey: "informativeIcon") ?? "🤓"
                    arr = (defaults.array(forKey: "informativeColor") as? [CGFloat] ?? Color("informative").toRGB())!
                    eventUIColor = UIColor(red: arr[0], green: arr[1], blue: arr[2], a: arr[3])
                }
                
                icon.text = "\t" + eventIcon + "\t"
                if event!.prediction {
                    icon.backgroundColor = predictionUIColor
                }
                else {
                    icon.backgroundColor = eventUIColor
                }
            }
            
            return icon
        }

        @MainActor
        func calendarView(_ calendarView: UICalendarView,
                          decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            // Do not mutate model objects here; return a decoration based on the cached arrays.
            if self.events.isEmpty {
                return .customView {
                    let icon = UILabel()
                    icon.text = ""
                    return icon
                }
            }
            
            let foundEvents = events
                .filter {$0.date.startOfDay == dateComponents.date?.startOfDay}
            if foundEvents.isEmpty {
                return .customView {
                    return self.initLabel(event: nil)
                }
            }

            if foundEvents.count > 1 {
                // Shouldn't happen
                return .image(UIImage(systemName: "doc.on.doc.fill"),
                              color: .red,
                              size: .large)
            }
            let singleEvent = foundEvents.first!
            return .customView {
                return self.initLabel(event: singleEvent)
            }
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate,
                           didSelectDate dateComponents: DateComponents?) {
            parent.dateSelected = dateComponents
            guard let dateComponents else { return }
            let foundEvents = events
                .filter {$0.date.startOfDay == dateComponents.date?.startOfDay}
            if !foundEvents.isEmpty {
                parent.displayEvents.toggle()
            }
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate,
                           canSelectDate dateComponents: DateComponents?) -> Bool {
            return true
        }
        
    }
    
    
}
