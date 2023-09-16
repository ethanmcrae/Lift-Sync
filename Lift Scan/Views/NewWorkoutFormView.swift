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
    let qrCode: String?
    var onComplete: ((Workout?) -> Void)
    @Binding var category: String

    var body: some View {
        Form {
            Section(header: Text("New Workout")) {
                TextField("Workout Name", text: $newWorkoutName)
                    .autocapitalization(.words)
                
                Picker("Category", selection: $category) {
                    ForEach(categoryManager.categories, id: \.self) { categoryName in
                        Text(categoryName)
                    }
                }
            }
            Section {
                Button(action: {
                    let trimmedName = newWorkoutName.trimmingCharacters(in: .whitespacesAndNewlines)
                    let absoluteCategory: String? = category.isEmpty ? nil : category
                    if !trimmedName.isEmpty {
                        let newWorkout = workoutManager.createWorkout(name: trimmedName, category: absoluteCategory, color: nil, qrCode: qrCode, categoryManager: categoryManager)
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
