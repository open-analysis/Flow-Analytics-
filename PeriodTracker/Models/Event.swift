
//
//  Event.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import SwiftUI
import SwiftData
import Foundation
import os

let oneDay: TimeInterval =  86400
// Current comparison is a week
let comparisonTime: TimeInterval = (oneDay * 7)

func getValues(type: EnumType) -> [[String]] {
    let logger = Logger(subsystem: "Event", category: "getValues")
    var values: [String] = []
    var selectedImgs: [String] = []
    var unselectedImgs: [String] = []
    var returnVal: [[String]] = [values, selectedImgs, unselectedImgs]
    
    switch type {
    case .flow :
        for enumCase in FlowType.allCases {
            values.append(enumCase.rawValue.capitalized)
            unselectedImgs.append("")
            selectedImgs.append("")
        }
        break
    case .spotting :
        for enumCase in SpottingType.allCases {
            values.append(enumCase.rawValue.capitalized)
            unselectedImgs.append("")
            selectedImgs.append("")
        }
        break
    case .clotting :
        for enumCase in ClottingType.allCases {
            values.append(enumCase.rawValue.capitalized)
            unselectedImgs.append("")
            selectedImgs.append("")
        }
        break
    case .feeling :
        for enumCase in FeelingType.allCases {
            values.append(enumCase.rawValue.capitalized)
            unselectedImgs.append("")
            selectedImgs.append("")
        }
        break
    case .pain :
        for enumCase in PainType.allCases {
            values.append(enumCase.rawValue.capitalized)
            unselectedImgs.append("")
            selectedImgs.append("")
        }
        break
    case .energy :
        for enumCase in EnergyType.allCases {
            values.append(enumCase.rawValue.capitalized)
            unselectedImgs.append("")
            selectedImgs.append("")
        }
        break
    }
    
    returnVal[0] = values
    returnVal[1] = selectedImgs
    returnVal[2] = unselectedImgs
    
    return returnVal
}

enum EnumType: Int {
    case flow, spotting, clotting, feeling, pain, energy
}

enum FlowType: String, Identifiable, CaseIterable, Codable {
    case none, very_light, light, moderate, heavy, very_heavy
    var id: String {
        self.rawValue
    }
}

enum SpottingType: String, Identifiable, CaseIterable, Codable {
    case none, brown_blood, red_blood
    var id: String {
        self.rawValue
    }
}

enum ClottingType: String, Identifiable, CaseIterable, Codable {
    case none, dime_sized, quarter_sized, half_dollar_or_larger
    var id: String {
        self.rawValue
    }
}

enum FeelingType: String, Identifiable, CaseIterable, Codable {
    case none, happy, sad, frustrated
    var id: String {
        self.rawValue
    }
}

enum PainType: String, Identifiable, CaseIterable, Codable {
    case none, very_light, light, moderate, heavy, very_heavy
    var id: String {
        self.rawValue
    }
}

enum EnergyType: String, Identifiable, CaseIterable, Codable {
    case none, exhausted, tired, normal, high_energy
    var id: String {
        self.rawValue
    }
}

enum EventType: String, Identifiable, CaseIterable, Codable {
    case none, menstrual, follicular, ovulation, luteal, informative
    
    var id: String {
        self.rawValue
    }
}

enum EventSchemaV1: VersionedSchema {
    
    static var versionIdentifier = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [Event.self]
    }
    
    @Model
    final class Event {
        var date: Date
        var prediction: Bool
        var name: String
        var eventType: EventType
        var flowType: FlowType
        var spottingType: [SpottingType]
        var clottingType: ClottingType
        var energyType: EnergyType
        var feelingType: [FeelingType]
        var painType: PainType
        
        var dateComponents: DateComponents {
            var dateComponents = Calendar.current.dateComponents(
                [.month,
                 .day,
                 .year],
                from: date)
            dateComponents.timeZone = TimeZone.current
            dateComponents.calendar = Calendar(identifier: .gregorian)
            self.name = "menstrual_\(String(self.prediction))_\(dateComponents.year!)_\(dateComponents.month!)_\(dateComponents.day!)"
            return dateComponents
        }
        
        init(date: Date,
             prediction: Bool = false,
             eventType: EventType = EventType.none,
             flowType: FlowType = FlowType.none,
             spottingType: [SpottingType] = [],
             clottingType: ClottingType = ClottingType.none,
             energyType: EnergyType = EnergyType.none,
             feelingType: [FeelingType] = [],
             painType: PainType = PainType.none) {
            self.eventType = eventType
            self.flowType = flowType
            self.spottingType = spottingType
            self.clottingType = clottingType
            self.energyType = energyType
            self.feelingType = feelingType
            self.painType = painType
            self.date = date.startOfDay
            self.prediction = prediction
            self.name = "event_E_P_YYYY_MM_DD"
        }
    }
}

typealias Event = EventSchemaV1.Event
