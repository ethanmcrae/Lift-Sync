//
//  AverageWeightView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/8/23.
//

import SwiftUI
import Charts

struct AverageWeightView: View {
    var data: [Date: Double]
    
    var sortedData: [(key: Date, value: Double)] {
        return data.sorted(by: { $0.key < $1.key })
    }
    
    var body: some View {
        Chart {
            // Horizontal line:
//            RuleMark(y: .value("Max", sortedData.last?.value ?? 0))
            
            ForEach(Array(sortedData.enumerated()), id: \.offset) { index, entry in
                let dateString = DateFormatter.dateOnly.string(from: entry.key)
                
                LineMark(
                    x: .value("Date", dateString),
                    y: .value("Weight", entry.value)
                )
                PointMark(
                    x: .value("Date", dateString),
                    y: .value("Weight", entry.value)
                )
            }
        }
    }
}

struct AverageWeightView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutManager = PreviewManager.mockWorkoutManager()
        let selectedWorkout = "Workout Preview"

        return AverageWeightView(data: workoutManager.averageWeight(for: selectedWorkout))
    }
}
