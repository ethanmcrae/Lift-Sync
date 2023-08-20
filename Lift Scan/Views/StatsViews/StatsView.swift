//
//  StatsView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/8/23.
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State var selectedWorkout: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Frequency of Workouts over Time
                WorkoutsFrequencyView(data: workoutManager.workoutsPerDate())
                
                // Workout picker for the weight over time graph
                PickerWorkoutWeightView(workoutManager: workoutManager, selectedWorkout: $selectedWorkout)
                
                // Graph of the weight progression
                if selectedWorkout != nil {
                    AverageWeightView(data: workoutManager.weightHistory(for: selectedWorkout!))
                }
            }
            .padding()
        }
        .navigationBarTitle("Stats", displayMode: .inline)
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutManager = PreviewManager.mockWorkoutManager()

        return StatsView()
            .environmentObject(workoutManager)
    }
}
