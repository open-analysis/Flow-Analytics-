//
//  SettingsNotificationsView.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import UserNotifications
import SwiftUI
import SwiftData


struct SettingsNotificationsView: View {
    let center = UNUserNotificationCenter.current()
    
    @State private var outputText: String = ""
    @State private var authorizationStatus: UNAuthorizationStatus?
    @Query(filter: predictionEventsPredicate()) private var predictedEvents: [Event]
    
    func getMostRecentEvent(eventType: EventType) -> Event? {
        var mostRecentEvent: Event? = nil
        var localComparisonTime = oneDay * 90
        if predictedEvents.count < 2 {
            return mostRecentEvent
        }
        
        
        for i in 0...predictedEvents.count-1 {
            if predictedEvents[i].eventType != eventType {
                continue
            }
            
            let dayDiff = (predictedEvents[i].date.startOfDay.timeIntervalSince1970 - predictedEvents[i-1].date.startOfDay.timeIntervalSince1970)
            // get the delta if the events are more than a week apart, assuming separate cycles
            if (dayDiff > 0 && dayDiff < localComparisonTime) {
                localComparisonTime = dayDiff
                mostRecentEvent = predictedEvents[i]
            }
        }
        
        return mostRecentEvent
    }
    
    var body: some View {
        VStack {
            if authorizationStatus == .authorized || authorizationStatus == .provisional {
                VStack {
                    Button("Notify before next period?") {
                        Task {
                            // Clear previous period notifications
                            center.removePendingNotificationRequests(withIdentifiers: ["period"])
                            
                            let mostRecentEvent = getMostRecentEvent(eventType: EventType.menstrual)
                            if mostRecentEvent == nil {
                                self.outputText = "Failed to find most recent event"
                            }
                            else {
                                let content = UNMutableNotificationContent()
                                content.title = "Upcoming cycle"
                                content.body = "Next period will be MM/DD"
                                
                                content.sound = .default
                                content.interruptionLevel = .active
                                
                                let identifier = "period"
                                
                                var date = DateComponents()
                                if (mostRecentEvent?.dateComponents.day!)! < 7 {
                                    var remainder = 0
                                    date.month = (mostRecentEvent?.dateComponents.month)! - 1
                                    for i in 1...7 {
                                        if ((mostRecentEvent?.dateComponents.day)! - i) == 0 {
                                            remainder = 7 - i
                                            break
                                        }
                                    }
                                    // Being lazy & taking the easiest path out
                                    date.day = 28 - remainder

                                }
                                else {
                                    date.month = mostRecentEvent?.dateComponents.month!
                                    date.day = mostRecentEvent?.dateComponents.day!
                                }
                                date.hour = 12
                                date.minute = 0
                                
                                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
                                
                                center.add(UNNotificationRequest(identifier: identifier,
                                                                 content: content,
                                                                 trigger: trigger))
                                
                                self.outputText = "Done! You will be notified for your next period on \(date.month!)/\(date.day!)"
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle)
                    Button("Notify before next fertility window?") {
                        Task {
                            // Clear previous period notifications
                            center.removePendingNotificationRequests(withIdentifiers: ["ovulation"])
                            
                            let mostRecentEvent = getMostRecentEvent(eventType: EventType.ovulation)
                            if mostRecentEvent == nil {
                                self.outputText = "Failed to find most recent event"
                            }
                            else {
                                let content = UNMutableNotificationContent()
                                content.title = "Upcoming cycle"
                                content.body = "Next ovulation cycle will be MM/DD"
                                
                                content.sound = .default
                                content.interruptionLevel = .active
                                
                                let identifier = "ovulation"
                                
                                var date = DateComponents()
                                if (mostRecentEvent?.dateComponents.day!)! < 7 {
                                    var remainder = 0
                                    date.month = (mostRecentEvent?.dateComponents.month)! - 1
                                    for i in 1...7 {
                                        if ((mostRecentEvent?.dateComponents.day)! - i) == 0 {
                                            remainder = 7 - i
                                            break
                                        }
                                    }
                                    // Being lazy & taking the easiest path out
                                    date.day = 28 - remainder

                                }
                                else {
                                    date.month = mostRecentEvent?.dateComponents.month!
                                    date.day = mostRecentEvent?.dateComponents.day!
                                }
                                date.hour = 12
                                date.minute = 0
                                
                                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
                            
                                center.add(UNNotificationRequest(identifier: identifier,
                                                                 content: content,
                                                                 trigger: trigger))
                            
                                self.outputText = "Done! You will be notified for your next fertility window on \(date.month!)/\(date.day!)"
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle)
                }
            }
            else {
                Button("Setup notifications") {
                    Task {
                        do {
                            try await center.requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { (granted, error) in
                                print("Permission granted: \(granted)")
                            }
                        } catch {
                            print("Error requesting premissions")
                        }
                        self.outputText = "Granted! Re-open settings to enable notifications!"
                    }
                }
                .buttonBorderShape(.roundedRectangle)
                .buttonStyle(.borderedProminent)
            }
            Text(outputText).font(.system(.title3))
        }
        .task {
            let settings = await center.notificationSettings()
            authorizationStatus = settings.authorizationStatus
        }
    }
}
