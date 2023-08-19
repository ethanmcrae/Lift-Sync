//
//  StatsView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/8/23.
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Frequency of Workouts over Time
                WorkoutsFrequencyView(data: workoutManager.workoutsPerDate())
                
                // Average Weight over Time for a selected workout
                PickerWorkoutWeightView(workoutManager: workoutManager)
                
                // More statistics views can be added here
            }
            .padding()
        }
        .navigationBarTitle("Stats", displayMode: .inline)
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        let persistentContainer = PreviewManager.container()
        let workoutManager = WorkoutManager(container: persistentContainer)

        return StatsView()
            .environmentObject(workoutManager)
    }
}
