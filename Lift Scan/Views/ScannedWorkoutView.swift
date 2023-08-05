//
//  ScannedWorkoutView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/1/23.
//

import SwiftUI

struct ScannedWorkoutView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var showLogForm = false
    @State private var showingDeleteAlert = false
    @State private var workoutLogToDelete: WorkoutLog?

    var workout: Workout
    
    private func deleteWorkoutLogs(at offsets: IndexSet) {
        guard let logs = workout.logs?.allObjects as? [WorkoutLog] else { return }
        for index in offsets {
            workoutManager.deleteLog(logs[index])
        }
    }

    var body: some View {
        VStack {
            Text(workout.name ?? "Removed")
            Button("Log New Workout") {
                showLogForm = true
            }
            .sheet(isPresented: $showLogForm) {
                NewWorkoutLogFormView(isPresenting: $showLogForm, workout: workout, onComplete: { workoutLog in
                    workoutManager.updateCloud(errorMessage: "Failed to save log")
                    showLogForm = false
                })
            }
            List {
                ForEach(workout.logs?.allObjects as? [WorkoutLog] ?? [], id: \.self) { log in
                    VStack(alignment: .leading) {
                        HStack(alignment: .bottom, spacing: 0) {
                            Text("\(log.sets) x \(log.reps): ")
                            ForEach((log.weights?.allObjects as? [Weight] ?? []).sorted(by: { $0.index < $1.index }), id: \.self) { weight in
                                Text("\(weight.weightValue) ").foregroundColor(weight.incomplete ? .yellow : .primary)
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    if let index = indexSet.first, let logs = workout.logs?.allObjects as? [WorkoutLog] {
                        workoutLogToDelete = logs[index]
                        showingDeleteAlert = true
                    }
                }
            }
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete workout log?"),
                message: Text("Are you sure you want to delete this workout log? This cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    if let workoutLogToDelete = workoutLogToDelete {
                        workoutManager.deleteLog(workoutLogToDelete)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct ScannedWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        let container = previewContainer()
        let context = container.viewContext
        let workout = Workout(context: context)
        workout.name = "Workout Preview"
        // Add any other properties you want for your preview

        // Create a workoutLog for the workout
        let workoutLog = WorkoutLog(context: context)
        workoutLog.date = Date()
        workoutLog.reps = 10
        workoutLog.sets = 5
        
        // Create a weight for the workoutLog
        let weight1 = Weight(context: context)
        weight1.weightValue = 100
        weight1.index = 0
        workoutLog.addToWeights(weight1)
        
        // Create a weight for the workoutLog
        let weight2 = Weight(context: context)
        weight2.weightValue = 110
        weight2.index = 1
        workoutLog.addToWeights(weight2)
        
        // Create a weight for the workoutLog
        let weight3 = Weight(context: context)
        weight3.weightValue = 115
        weight3.index = 2
        workoutLog.addToWeights(weight3)

        // Add the workoutLog to the workout
        workout.addToLogs(workoutLog)

        return ScannedWorkoutView(workout: workout)
            .environmentObject(WorkoutManager(container: container))
    }
}
