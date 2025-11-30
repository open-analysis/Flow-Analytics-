//
//  ListViewRow.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import SwiftUI

struct ListViewRow: View {
    let event: Event
    let showAll: Bool
    @Binding var formType: EventFormType?
    @Binding var updatedRecently: Bool
    let defaults = UserDefaults.standard
    @State private var menstrualIcon: String = ""
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    VStack {
                        Text(event.eventType.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                        if event.prediction {
                            Text("Prediction")
                        }
                    }
                        
                    VStack {
                        if event.flowType != FlowType.none {
                            Text(event.flowType.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                        }
                        if event.clottingType != ClottingType.none {
                            Text(event.clottingType.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                        }
                        ForEach(event.spottingType) { spotting in
                            if spotting != SpottingType.none {
                                Text(spotting.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                            }
                        }
                    }
                    VStack {
                        if event.energyType != EnergyType.none {
                            Text(event.energyType.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                        }
                        if event.painType != PainType.none {
                            Text(event.painType.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                        }
                        ForEach(event.feelingType) { feeling in
                            if feeling != FeelingType.none {
                                Text(feeling.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                            }
                        }
                    }
                }
                Text(
                    event.date.formatted(date: .abbreviated,
                                         time: .shortened)
                )
            }
            Spacer()
            Button {
                formType = .update(event)
                updatedRecently = true
            } label: {
                Text("Edit")
            }
            .buttonStyle(.bordered)
        }.onAppear {
            menstrualIcon = defaults.string(forKey: "menstrualIcon") ?? "?"
        }
    }
}


