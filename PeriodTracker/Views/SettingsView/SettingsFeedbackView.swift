//
//  SettingsFeedbackView.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import UserNotifications
import SwiftUI
import SwiftData


struct SettingsFeedbackView: View {
    @Environment(\.openURL) private var openURL
    
    let feedbackText = """
        Please provide feedback about things with the app.
        What is difficult or hard to use? Is there anything unclear?
        Feedback is helpful to make this better in the future :) 
        """
    let supportText = """
        Support is much appreciated, but not necessary.
        It helps to let me focus my attention on development
        """
    
    var body: some View {
        VStack {
            Text("Help make the app better with feedback or support").font(.title)
            Spacer()
            Text("Feedback").font(.title2)
            Text(feedbackText)
            Button("Feedback") {
                if let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSfRQft2Ji88UEs_0uhK8-Vl7UjPBjwxzH5ZjEtUw4rMUsW37Q/viewform?usp=dialog") {
                    openURL(url)
                }
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle)
            Spacer()
            Text("Support the devs").font(.title2)
            Text(supportText)
            Button("Support - Ko-fi") {
                if let url = URL(string: "https://ko-fi.com/opnanalysis") {
                    openURL(url)
                }
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle)
            Spacer()
        }
    }
}
