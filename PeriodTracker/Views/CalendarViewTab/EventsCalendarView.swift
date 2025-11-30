//
//  EventsCalendarView.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import SwiftUI
import SwiftData

struct EventsCalendarView: View {
    @Environment(\.modelContext) private var context
    @Binding var updatedRecently: Bool
    @State private var dateSelected: DateComponents?
    @State private var displayEvents = false
    @State private var formType: EventFormType?
    let defaults = UserDefaults.standard
    private var bgColor: Color
    private var bgColorGradient: Color
    private var isGradient = false
    private var backgroundGradient: LinearGradient
    
    init(updatedRecently: Binding<Bool>) {
        self._updatedRecently = updatedRecently
        // Set defaults
        self.bgColor = Color(.gray)
        self.isGradient = false
        self.bgColorGradient = Color(.gray)
        self.backgroundGradient = LinearGradient(colors: [Color.gray, Color.gray],startPoint: .top, endPoint: .bottom)
        
        var uiColor: UIColor = UIColor(.gray)
        var arr: [CGFloat] = []
        arr = (defaults.array(forKey: "bgColor") as? [CGFloat] ?? Color(.lightGray).toRGB())!
        uiColor = UIColor(red: arr[0], green: arr[1], blue: arr[2], a: arr[3])
        self.bgColor = Color(uiColor)
        arr = (defaults.array(forKey: "bgColorGradient") as? [CGFloat] ?? Color(.lightGray).toRGB())!
        uiColor = UIColor(red: arr[0], green: arr[1], blue: arr[2], a: arr[3])
        self.bgColorGradient = Color(uiColor)
        self.isGradient = defaults.bool(forKey: "isGradient")
        
        if self.isGradient {
            self.backgroundGradient = LinearGradient(
                colors: [bgColor, bgColorGradient],
                startPoint: .top, endPoint: .bottom)
        }
        else {
            self.backgroundGradient = LinearGradient(
                colors: [bgColor, bgColor],
                startPoint: .top, endPoint: .bottom)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    CalendarView(interval: DateInterval(start: .distantPast, end: .distantFuture),
                                 dateSelected: $dateSelected,
                                 displayEvents: $displayEvents,
                                 updatedRecently: $updatedRecently)
                }
                PredictionView(updatedRecently: $updatedRecently)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        // Track button
                        Button {
                            formType = .new
                            updatedRecently = true
                        } label: {
                            VStack {
                                Image(systemName: "plus.circle.fill")
                                    .imageScale(.large)
                                Text("Track").font(.system(size: 20))
                            }
                        }
                        // Stats button
                        NavigationLink {
                            StatsListView(updatedRecently: $updatedRecently)
                        } label: {
                            VStack {
                                Image(systemName: "pencil.circle")
                                    .imageScale(.large)
                                Text("Stats").font(.system(size: 20))
                            }
                        }
                        // Settings button
                        NavigationLink {
                            SettingsView()
                        } label: {
                            VStack {
                                Image(systemName: "slider.horizontal.3")
                                    .imageScale(.large)
                                Text("Settings").font(.system(size: 20))
                            }
                        }
                    }
                }
            }
            // Use the factory to pass the updatedRecently binding into the EventFormView
            .sheet(item: $formType) { form in
                form.makeView(updatedRecently: $updatedRecently)
            }
            .sheet(isPresented: $displayEvents) {
                DaysEventsListView(dateSelected: $dateSelected, updatedRecently: $updatedRecently)
                    .presentationDetents([.medium, .large])
            }
            .background(backgroundGradient)
        }
    }
}
