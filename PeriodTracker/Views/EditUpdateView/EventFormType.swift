//
//  EventFormType.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import SwiftUI

// EventFormType no longer directly conforms to View; it is an enum helper that can produce a EventFormView when requested
enum EventFormType: Identifiable {
    case new
    case update(Event)
    var id: String {
        switch self {
        case .new:
            return "new"
        case .update:
            return "update"
        }
    }

    // Factory that returns EventFormView with the updatedRecently binding passed-through
    func makeView(updatedRecently: Binding<Bool>) -> some View {
        switch self {
        case .new:
            return EventFormView(viewModel: EventFormViewModel(), updatedRecently: updatedRecently)
        case .update(let event):
            return EventFormView(viewModel: EventFormViewModel(event), updatedRecently: updatedRecently)
        }
    }
}
