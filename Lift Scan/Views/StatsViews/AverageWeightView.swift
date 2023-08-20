//
//  AverageWeightView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/8/23.
//

import SwiftUI
import Charts

struct AverageWeightView: View {
    var data: [Date: [(reps: Int, weight: Int)]]
    
    var chronologicalData: [(key: Date, value: [(reps: Int, weight: Int)])] {
        return data.sorted(by: { $0.key < $1.key })
    }
    
    var body: some View {
        Chart {
            ForEach(0..<chronologicalData.count, id: \.self) { index in
                let entry = chronologicalData[index]
                let dateString = DateFormatter.dateOnly.string(from: entry.key)
                
                let maxWeight = entry.value.max(by: { $0.weight < $1.weight })?.weight
                let minWeight = entry.value.max(by: { $1.weight < $0.weight })?.weight
                
                PointMark(
                    x: .value("Date", dateString),
                    y: .value("Weight", maxWeight ?? 0)
                )
                .symbolSize(200.0)
                .foregroundStyle(Color.green.opacity(0.75))
                PointMark(
                    x: .value("Date", dateString),
                    y: .value("Weight", minWeight ?? 0)
                )
                .symbolSize(200.0)
                .foregroundStyle(Color.yellow.opacity(0.75))
                
                ForEach(entry.value.indices, id: \.self) { valueIndex in
                    let workoutSet = entry.value[valueIndex]
                    PointMark(
                        x: .value("Date", dateString),
                        y: .value("Weight", workoutSet.weight)
                    )
                }
            }
        }
    }
}

struct AverageWeightView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutManager = PreviewManager.mockWorkoutManager()
        let selectedWorkout = "Crunches"

        return AverageWeightView(data: workoutManager.weightHistory(for: selectedWorkout))
    }
}
