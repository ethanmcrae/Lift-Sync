//
//  PickerWorkoutWeightView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/8/23.
//

import SwiftUI

struct PickerWorkoutWeightView: View {
    @ObservedObject var workoutManager: WorkoutManager
    @State private var selectedWorkout: String?
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Average Weight over Time")
                .font(.headline)
            
            Picker("Select Workout", selection: $selectedWorkout) {
                ForEach(Array(workoutManager.workouts.keys), id: \.self) { category in
                    ForEach(Array(workoutManager.workouts[category]!), id: \.self) { workout in
                        Text(workout.name ?? "Unknown").tag(workout.name ?? "")
                    }
                }
            }
            .pickerStyle(InlinePickerStyle())
            .onChange(of: selectedWorkout) { newValue in
                selectedWorkout = newValue ?? ""
                print("Selected workout \(newValue ?? "-")")
            }
            
            if selectedWorkout != nil {
                AverageWeightView(data: workoutManager.averageWeight(for: selectedWorkout!))
            }
        }
    }
}

struct PickerWorkoutWeightView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutManager = PreviewManager.mockWorkoutManager()

        return PickerWorkoutWeightView(workoutManager: workoutManager)
            .environmentObject(workoutManager)
    }
}
