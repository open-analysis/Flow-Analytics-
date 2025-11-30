//
//  DaysEvents.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import SwiftUI
import SwiftData


struct DaysEventsListView: View {
    @Environment(\.modelContext) private var context
    @Binding var dateSelected: DateComponents?
    @State private var formType: EventFormType?
    @Binding var updatedRecently: Bool
    @Query private var events: [Event]
    
    var body: some View {
        NavigationStack {
            Group {
                if let dateSelected {
                    let foundEvent = events
                        .filter {$0.date.startOfDay == dateSelected.date!.startOfDay}
                    List {
                            ForEach(foundEvent) { event in
                            ListViewRow(event: event, showAll: true, formType: $formType, updatedRecently: $updatedRecently)
                            .swipeActions {
                                Button(role: .destructive) {
                                    context.delete(event.self)
                                    // ensure calendar and stats update after deletion
                                    updatedRecently = true
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                            .sheet(item: $formType) { form in
                                form.makeView(updatedRecently: $updatedRecently)
                            }
                        }
                    }
                }
            }
            .navigationTitle(dateSelected?.date?.formatted(date: .long, time: .omitted) ?? "")
        }
    }
}
