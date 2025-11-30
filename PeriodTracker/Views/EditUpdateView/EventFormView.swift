//
//  EventFormView.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import SwiftUI
import SwiftData

struct EventFormView: View {
    @Environment(\.modelContext) private var context
    @State private var statDuration: TimeInterval = 0
    @State private var outliers: [Event:Int] = [:]
    @State private var updateInfo: String = ""
    @State private var selectedFlow: String = "None"
    @State private var selectedClotting: String = "None"
    @State private var selectedSpotting: String = "None"
    @State private var selectedFeeling: String = "None"
    @State private var selectedPain: String = "None"
    @State private var selectedEnergy: String = "None"
    @StateObject var viewModel: EventFormViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focus: Bool?
    @Binding var updatedRecently: Bool
    @Query(filter: nonPredictionEventsPredicate()) private var events: [Event]
    @Query(filter: predictionEventsPredicate()) private var predictedEvents: [Event]
    @Query(filter: durationPredicate()) private var durationStats: [Stats]
    
    func updateEventArray(updatedEvent: Event) {
        for event in events {
            if event.date.startOfDay == updatedEvent.date.startOfDay {
                event.date = updatedEvent.date
                event.flowType = updatedEvent.flowType
                event.clottingType = updatedEvent.clottingType
                event.spottingType = updatedEvent.spottingType
                event.energyType = updatedEvent.energyType
                event.feelingType = updatedEvent.feelingType
                event.painType = updatedEvent.painType
                if (event.flowType != FlowType.none) || (event.clottingType != ClottingType.none) {
                    event.eventType = EventType.menstrual
                }
                else {
                    event.eventType = EventType.informative
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    DatePicker(selection: $viewModel.date, displayedComponents: [.date]) {
                        Text("Date")
                    }
                    VStack {
                        Text("Flow")
                        RadioButtonGroup(options: FlowType.allCases,    label: {$0.rawValue}, selectedOption: $viewModel.flowType)
                    }
                    VStack {
                        Text("Clotting")
                        RadioButtonGroup(options: ClottingType.allCases,label: {$0.rawValue}, selectedOption: $viewModel.clottingType)
                    }
                    VStack {
                        Text("Spotting")
                        RadioButtonMultiSelectGroup(options: SpottingType.allCases,label: {$0.rawValue}, selectedOption: $viewModel.spottingType)
                    }
                    VStack {
                        Text("Feeling")
                        RadioButtonMultiSelectGroup(options: FeelingType.allCases, label: {$0.rawValue}, selectedOption: $viewModel.feelingType)
                    }
                    VStack {
                        Text("Energy")
                        RadioButtonGroup(options: EnergyType.allCases,  label: {$0.rawValue}, selectedOption: $viewModel.energyType)
                    }
                    VStack {
                        Text("Pain")
                        RadioButtonGroup(options: PainType.allCases,    label: {$0.rawValue}, selectedOption: $viewModel.painType)
                    }
                    Section(footer:
                        VStack {
                            Text(updateInfo)
                            HStack {
                                Spacer()
                                Button {
                                    var currEvent: Event = Event(date: Date())
                                    statDuration = 0
                                    for stat in durationStats {
                                        if stat.type == "menstrual-duration" {
                                            statDuration = stat.value
                                            break
                                        }
                                    }
                                    if viewModel.updating {
                                        // update this event (in-memory update based on existing Query results)
                                        let updatedEvent = Event(date: viewModel.date,
                                                                 flowType: viewModel.flowType,
                                                                 spottingType: viewModel.spottingType,
                                                                 clottingType: viewModel.clottingType,
                                                                 energyType: viewModel.energyType,
                                                                 feelingType: viewModel.feelingType,
                                                                 painType: viewModel.painType)
                                        updateEventArray(updatedEvent: updatedEvent)
                                        currEvent = updatedEvent
                                    } else {
                                        // If there's no event already at this point in time, make a new one
                                        var possible_name: String = ""
                                        for event in events {
                                            if event.date.startOfDay == viewModel.date.startOfDay {
                                                possible_name = event.name
                                                break
                                            }
                                        }
                                        if possible_name == "" {
                                            // create new event
                                            let newEvent = Event(date: viewModel.date.startOfDay,
                                                                 flowType: viewModel.flowType,
                                                                 spottingType: viewModel.spottingType,
                                                                 clottingType: viewModel.clottingType,
                                                                 energyType: viewModel.energyType,
                                                                 feelingType: viewModel.feelingType,
                                                                 painType: viewModel.painType)
                                            if (newEvent.flowType != FlowType.none) || (newEvent.clottingType != ClottingType.none) {
                                                newEvent.eventType = EventType.menstrual
                                            }
                                            else {
                                                newEvent.eventType = EventType.informative
                                            }
                                            context.insert(newEvent)
                                            currEvent = newEvent
                                        }
                                        // If there's an event here, update instead of adding a new one
                                        else {
                                            let updatedEvent = Event(date: viewModel.date.startOfDay,
                                                                     flowType: viewModel.flowType,
                                                                     spottingType: viewModel.spottingType,
                                                                     clottingType: viewModel.clottingType,
                                                                     energyType: viewModel.energyType,
                                                                     feelingType: viewModel.feelingType,
                                                                     painType: viewModel.painType)
                                            updateEventArray(updatedEvent: updatedEvent)
                                            currEvent = updatedEvent
                                        }
                                    }
                                    (statDuration, outliers) = updatePrediction(events: events, i_predictionEvents: predictedEvents)
                                    
                                    // Important: tell CalendarView / other views to refresh
                                    updatedRecently = true
                                    updateInfo = "\(currEvent.dateComponents.month!)/\(currEvent.dateComponents.day!) updated!"
                                } label: {
                                    Text(viewModel.updating ? "Update" : "Track")
                                }
                                .buttonStyle(.borderedProminent)
                                Spacer()
                                Button {
                                    dismiss()
                                } label: {
                                    Text("Exit")
                                }
                                .buttonStyle(.borderedProminent)
                                Spacer()
                            }
                        }
                    ) {
                        EmptyView()
                    }
                }
            }
            .navigationTitle(viewModel.updating ? "Update" : "Track")
            .onAppear {
                focus = true
            }
        }
    }
}
