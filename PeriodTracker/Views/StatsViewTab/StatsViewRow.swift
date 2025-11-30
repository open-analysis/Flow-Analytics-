//
//  StatsViewRow.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import SwiftUI

struct StatsViewRow: View {
    var stat: Stats
    let index: String.Index
    
    func getStatType(type: String, index: String.Index) -> String {
        let formatedTypes = ["Avg Duration:", "Typical Start\nDate:", "Std Dev:", "Outlier Count:", "Outlier:"]
        let statType = type[index...]
        
        if statType == "-duration" {
            return formatedTypes[0]
        }
        else if statType == "-typicalStartDate" {
            return formatedTypes[1]
        }
        else if statType == "-stdDev" {
            return formatedTypes[2]
        }
        else if statType == "-outlierCount" {
            return formatedTypes[3]
        }
//        else if statType.contains("-outlier") {
//            return formatedTypes[4]
//        }
        
        return ""
    }
    
    func printStatValue(type:String, index: String.Index, value: Double) -> String {
        let statType = type[index...]
        
        if statType == "-duration" {
            return String(format:"%.1f days", value)
        }
        else if statType == "-typicalStartDate" {
            return String(format:"Day %.0f of the month", value)
        }
        else if statType == "-stdDev" {
            return String(format: "%.2f", value)
        }
        else if statType == "-outlierCount" {
            return String(format: "%.0f outliers", value)
        }
        
        return ""
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                VStack {
                    HStack {
                        Text(getStatType(type: stat.type, index: index))
                            .font(.system(size: 20))
                        Text(printStatValue(type: stat.type, index: index, value: stat.value))
                            .font(.system(size: 30))
                    }
                    Text(stat.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 10))
                }
            }
        }
    }
}

 
