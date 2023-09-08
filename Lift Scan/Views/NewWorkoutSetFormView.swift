//
//  NewWorkoutSetFormView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/4/23.
//

import SwiftUI

struct NewWorkoutSetFormView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    var workout: Workout
    @Binding var weight: Float
    @Binding var reps: Int16
    @Binding var complete: Bool
    var onSubmit: () -> Void

    var body: some View {
        VStack {
            Section(header: Text("Record Set").font(.title2).padding(.bottom, 20)) {
                HStack {
                    // Reps picker wheel
                    VStack {
                        Text("Reps")
                            .font(.subheadline)
                        RepsPicker(reps: $reps)
                    }
                    // Weight picker wheel
                    VStack {
                        Text("Weight")
                            .font(.subheadline)
                        WeightPicker(weight: $weight)
                    }
                    // Complete radio button
                    VStack {
                        Text("Complete")
                            .font(.subheadline)
                        Spacer()
                        Button(action: {
                            complete.toggle()
                        }) {
                            if complete {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                    .foregroundColor(Color("BackgroundInvertedColor"))
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                    .foregroundColor(Color(.orange))
                            }
                        }
                        Spacer()
                    }
                }
            }
            Section {
                // Log New Workout Button
                Button(action: {
                    workoutManager.recordSet(reps: reps, weight: weight, workout: workout)
                    onSubmit()
                }, label: {
                    HStack(alignment: .center, spacing: 2) {
                        Image(systemName: "plus.circle")
                            .font(.title2)
                            .foregroundColor(Color("TextAccentColor"))
                        Text("Record Sets")
                            .font(.title3)
                            .foregroundColor(Color("TextAccentColor"))
                            .padding(12)
                    }
                })
//                .padding()
                .padding(.bottom, 20)
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

struct NewWorkoutSetFormView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutManager = PreviewManager.mockWorkoutManager()
        let workout = workoutManager.workouts["Legs"]!.first!
        @State var weight: Float = 120.0
        @State var reps: Int16 = 12
        @State var complete = false

        return NewWorkoutSetFormView(workout: workout, weight: $weight, reps: $reps, complete: $complete, onSubmit: {})
            .environmentObject(workoutManager)
    }
}
