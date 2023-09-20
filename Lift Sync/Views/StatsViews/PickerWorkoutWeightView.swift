//
//  PickerWorkoutWeightView.swift
//  Lift Sync
//
//  Created by Ethan McRae on 8/8/23.
//

import SwiftUI

struct PickerWorkoutWeightView: View {
    @ObservedObject var workoutManager: WorkoutManager
    @Binding var selectedWorkout: String?
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Average Weight over Time")
                .font(.headline)
            
            Picker("Select Workout", selection: $selectedWorkout) {
                ForEach(workoutManager.allWorkouts, id: \.name) { workout in
                    Text(workout.name ?? "Unknown").tag(workout.name ?? "")
                }
            }
            .pickerStyle(InlinePickerStyle())
            .onChange(of: selectedWorkout) { newValue in
                selectedWorkout = newValue ?? ""
            }
        }
    }
}

struct PickerWorkoutWeightView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutManager = PreviewManager.mockWorkoutManager()
        @State var selectedWorkout: String?

        return PickerWorkoutWeightView(workoutManager: workoutManager, selectedWorkout: $selectedWorkout)
            .environmentObject(workoutManager)
    }
}
