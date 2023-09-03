//
//  AverageWeightView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/8/23.
//

import SwiftUI
import Charts

struct AverageWeightView: View {
    var data: [Date: [(reps: Int, weight: Float)]]
    
    var chronologicalData: [(key: Date, value: [(reps: Int, weight: Float)])] {
        return data.sorted(by: { $0.key < $1.key })
    }
    
    var body: some View {
        var averageLinemark: [PointMark] = []
        Chart {
            ForEach(0..<chronologicalData.count, id: \.self) { index in
                let entry = chronologicalData[index]
                let dateString = DateFormatter.dateOnly.string(from: entry.key)
                
                let maxWeight = entry.value.max(by: { $0.weight < $1.weight })?.weight
                let minWeight = entry.value.max(by: { $1.weight < $0.weight })?.weight
                
                // Maximum
                LineMark(
                    x:.value("Date", dateString),
                    y: .value("Weight", maxWeight ?? 0.0 as Float)
                )
                .foregroundStyle(Color("BackgroundInvertedColor"))
                PointMark(
                    x: .value("Date", dateString),
                    y: .value("Weight", maxWeight ?? 0.0 as Float)
                )
                .symbolSize(150.0)
                .foregroundStyle(Color("BackgroundInvertedColor"))
                
                // Minimum
//                LineMark(
//                    x:.value("Date", dateString),
//                    y: .value("Weight", minWeight ?? 0.0 as Float)
//                )
//                .foregroundStyle(Color("BackgroundInvertedColor"))
                PointMark(
                    x: .value("Date", dateString),
                    y: .value("Weight", minWeight ?? 0.0 as Float)
                )
                .symbolSize(125.0)
                .foregroundStyle(Color("BackgroundInvertedColor"))
                
                // All reps
                ForEach(entry.value.indices, id: \.self) { valueIndex in
                    let workoutSet = entry.value[valueIndex]
                    PointMark(
                        x: .value("Date", dateString),
                        y: .value("Weight", workoutSet.weight)
                    )
                    .foregroundStyle(Color("BackgroundInvertedColor"))
                }
            }
        }
        .backgroundColor(Color("AccentColor-400"))
        .chartYScale(domain: .automatic)
        .chartXScale(domain: .automatic)
        .frame(minHeight: 200)
    }
}

struct AverageWeightView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutManager = PreviewManager.mockWorkoutManager()
        let selectedWorkout = "Crunches"

        return AverageWeightView(data: workoutManager.weightHistory(for: selectedWorkout))
    }
}
