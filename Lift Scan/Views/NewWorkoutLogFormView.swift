//
//  NewWorkoutLogFormView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/4/23.
//

import SwiftUI

struct NewWorkoutLogFormView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var isPresenting: Bool
    var workout: Workout
    @State var sets = ""
    @State var reps = ""
    // TODO: Engineer a way to not have this hardcoded (This is fixing an "Index out of range" error)
    @State var weights: [(value: Int, incomplete: Bool)] = [
        (0, false), (0, false), (0, false), (0, false), (0, false), (0, false), (0, false), (0, false), (0, false), (0, false), (0, false)
    ]
    var onComplete: (WorkoutLog) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sets & Reps")) {
                    TextField("Sets", text: $sets)
                        .keyboardType(.numberPad)
                        .onChange(of: sets) { newValue in
                            if Int(newValue) == nil {
                                sets = String(newValue.dropLast())
                            }
                        }
                    TextField("Reps", text: $reps)
                        .keyboardType(.numberPad)
                        .onChange(of: reps) { newValue in
                            if Int(newValue) == nil {
                                reps = String(newValue.dropLast())
                            }
                        }
                }
                if let setsInt = Int(sets) {
                    Section(header: Text("Weight")) {
                        ForEach(0..<setsInt, id: \.self) { index in
                            HStack {
                                TextField("Set # \(index+1)", text: Binding(
                                    get: {
                                        String(weights[index].value)
                                    },
                                    set: {
                                        if let value = Int($0) {
                                            weights[index].value = value
                                        }
                                    }
                                ))
                                .foregroundColor(weights[index].incomplete ? .yellow : .primary)
                                Toggle(isOn: Binding(
                                    get: { !weights[index].incomplete },
                                    set: { weights[index].incomplete = !$0 }
                                )) {
                                    Text("Complete")
                                }
                            }
                        }
                    }
                }
                Section {
                    Button(action: {
//                        let workoutLog = WorkoutLog(context: workoutManager.viewContext)
//                        workoutLog.date = Date()
//                        workoutLog.sets = Int16(sets) ?? 0
//                        workoutLog.reps = Int16(reps) ?? 0
//                        let filteredWeights = weights.filter { $0.value != 0 }
//                        for (index, weight) in filteredWeights.enumerated() {
//                            let weightEntity = Weight(context: workoutManager.viewContext)
//                            weightEntity.index = Int16(index)
//                            weightEntity.weightValue = Int16(weight.value)
//                            weightEntity.incomplete = weight.incomplete
//                            workoutLog.addToWeights(weightEntity)
//                        }
//                        workoutLog.workout = workout
                        
                        let workoutLog = workoutManager.createLog(workout: workout)
                        onComplete(workoutLog)
                    }) {
                        Text("Log Workout")
                    }
                }
            }
            .navigationTitle("Workout Log")
            .navigationBarItems(leading: Button("Cancel") {
                isPresenting = false
            })
        }
    }
}

struct NewWorkoutLogFormView_Previews: PreviewProvider {
    static var previews: some View {
        let container = PreviewManager.container()
        let context = container.viewContext
        let workout = Workout(context: context)
        @State var isPresenting = true
        workout.name = "Workout Preview"
        // Add any other properties you want for your preview

        return NewWorkoutLogFormView(isPresenting: $isPresenting, workout: workout, onComplete: {_ in })
            .environmentObject(WorkoutManager(container: container))
    }
}
