//
//  NewWorkoutFormView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/4/23.
//

import SwiftUI

struct NewWorkoutFormView: View {
    @EnvironmentObject var categoryManager: CategoryManager
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var isPresenting: Bool
    @State var newWorkoutName = ""
    var onComplete: ((Workout?) -> Void)

    var body: some View {
        Form {
            Section(header: Text("New Workout")) {
                TextField("Workout Name", text: $newWorkoutName)
            }
            Section {
                Button(action: {
                    let trimmedName = newWorkoutName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmedName.isEmpty, let newWorkout = workoutManager.createWorkout(name: trimmedName, category: nil, color: nil, categoryManager: categoryManager) {
                        newWorkoutName = ""
                        isPresenting = false
                        onComplete(newWorkout)
                    }
                }) {
                    Text("Create Workout")
                }
            }
            Section {
                Button(action: {
                    isPresenting = false
                    onComplete(nil)
                }) {
                    Text("Cancel")
                }
            }
        }
    }
}
