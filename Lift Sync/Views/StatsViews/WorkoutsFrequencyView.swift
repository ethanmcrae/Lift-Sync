//
//  WorkoutsFrequencyView.swift
//  Lift Sync
//
//  Created by Ethan McRae on 8/8/23.
//

import SwiftUI
import Charts

import SwiftUI

struct WorkoutsFrequencyView: View {
    var data: [Date: Int]
    var maxValue: Int { data.values.max() ?? 1 }

    var body: some View {
        VStack(spacing: 8) {
            Text("Frequency of Workouts")
                .font(.headline)
            
            // Bar Chart using Graph library
            Chart {
                ForEach(data.sorted(by: { $0.key < $1.key }), id: \.key) { date, count in
                    BarMark(
                        x: .value("Date", DateFormatter.dateOnly.string(from: date)),
                        y: .value("Count", Double(count))
                    )
                }
            }
            .frame(height: 200) // Adjust as needed
        }
    }
}

struct WorkoutsFrequencyView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutManager = PreviewManager.mockWorkoutManager()

        return WorkoutsFrequencyView(data: PreviewManager.mockData())
            .environmentObject(workoutManager)
    }
}
