//
//  EventFormViewModel.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import Foundation

class EventFormViewModel: ObservableObject {
    @Published var date = Date()
    @Published var name = ""
    @Published var flowType: FlowType = FlowType.none
    @Published var spottingType: [SpottingType] = []
    @Published var clottingType: ClottingType = ClottingType.none
    @Published var energyType: EnergyType = EnergyType.none
    @Published var feelingType: [FeelingType] = []
    @Published var painType: PainType = PainType.none

    var updating: Bool { name != "" }

    init() {}

    init(_ event: Event) {
        date = event.date
        name = event.name
    }
}
