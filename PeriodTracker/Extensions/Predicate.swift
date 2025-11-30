//
//  Predicate.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import SwiftData
import Foundation

//func eventPredicate(searchDate: Date = .now, searchInterval: TimeInterval = 365*3600*24, searchType: EventType = EventType.none) -> Predicate<Event> {
////    let year_in_sec: TimeInterval = 365*3600*24
//    let startOfSearch = searchDate.startOfDay-(searchInterval)
////    return #Predicate<Event> { event in
////        ((event.dateComponents.date!.startOfDay >= startOfSearch) &&
////         ((event.eventType == searchType) || (searchType == .none)))
////    }
//    return #Predicate<Event> { ($0.dateComponents.date!.startOfDay >= startOfSearch) &&
//         (($0.eventType == searchType) || (searchType == .none))
//    }
//}

func predictionEventsPredicate() -> Predicate<Event> {
    return #Predicate<Event> {
        $0.prediction
    }
}

func nonPredictionEventsPredicate() -> Predicate<Event> {
    return #Predicate<Event> {
        !$0.prediction
    }
}

func eventsPredicate() -> Predicate<Event> {
    let searchDate: Date = .now
    let searchInterval: TimeInterval = 365*3600*24
    let startOfSearch = searchDate.startOfDay-(searchInterval)
    
    return #Predicate<Event> {
        $0.dateComponents.date!.startOfDay >= startOfSearch
    }
}

func durationPredicate() -> Predicate<Stats> {
    return #Predicate<Stats> {
        $0.type == "menstrual-duration"
    }
}

