//
//  MoodChartView.swift
//  mobiilirakendused
//
//  Created by Pille Allvee on 20.04.2023.
//

import Foundation
import SwiftUI

struct MoodChartView: View {
    @State var moodHistory: [Mood]
    
    var moodCounts: [String: Int] {
        Dictionary(grouping: moodHistory, by: { $0.mood })
            .mapValues { $0.count }
    }
    
    var activityCounts: [String: Int] {
        Dictionary(grouping: moodHistory, by: { $0.activity })
            .mapValues { $0.count }
    }
    
    var personCounts: [String: Int] {
        Dictionary(grouping: moodHistory, by: { $0.personWith })
            .mapValues { $0.count }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                if !moodHistory.isEmpty {
                    moodPieChart
                        .padding()
                    activityBarChart
                        .padding()
                    personBarChart
                        .padding()
                } else {
                    Text("You haven't logged any moods yet.")
                        .padding()
                }
            }
        }
        .navigationTitle("Mood Charts")
    }
    
    private var moodPieChart: some View {
        let moodData = moodCounts.map { ChartData(name: $0.key, value: Double($0.value)) }
        let colors = moodColors.values.map { $0.uiColor }
        return PieChartView(data: moodData, colors: colors)
            .frame(height: 300)
    }
    
    private var activityBarChart: some View {
        let activityData = activityCounts.map { ChartData(name: $0.key, value: Double($0.value)) }
        let colors = activityTypes.map { moodColors[$0]!.uiColor }
        return BarChartView(data: activityData, colors: colors)
            .frame(height: 300)
    }
    
    private var personBarChart: some View {
        let personData = personCounts.map { ChartData(name: $0.key, value: Double($0.value)) }
        let colors = persons.map { moodColors["😄"]!.uiColor }
        return BarChartView(data: personData, colors: colors)
            .frame(height: 300)
    }
}
