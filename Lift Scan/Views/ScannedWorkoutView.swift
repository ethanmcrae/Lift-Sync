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
    var onDisappear: () -> Void
    
    private func deleteWorkoutLogs(at offsets: IndexSet) {
        guard let logs = workout.logs?.allObjects as? [WorkoutLog] else { return }
        for index in offsets {
            workoutManager.deleteLog(logs[index])
        }
    }

    var body: some View {
        VStack {
            Text(workout.name ?? "Removed")
                .font(.title)
                .padding(.bottom, 40)
            Button(action: {
                showLogForm = true
            }, label: {
                HStack(alignment: .center, spacing: 2) {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                        .foregroundColor(Color("TextAccentColor"))
                    Text("Log New Workout")
                        .font(.title3)
                        .foregroundColor(Color("TextAccentColor"))
                        .padding(12)
                }
            })
            .padding()
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $showLogForm) {
                NewWorkoutLogFormView(isPresenting: $showLogForm, workout: workout, onComplete: { workoutLog in
                    workoutManager.updateCloud(errorMessage: "Failed to save log")
                    showLogForm = false
                })
            }

            List {
                ForEach(workout.logs?.allObjects as? [WorkoutLog] ?? [], id: \.self) { log in
                    VStack(alignment: .leading) {
                        ScrollView(.horizontal) {
                            ForEach(log.sets?.allObjects as? [WorkoutSet] ?? [], id: \.self) { workoutSet in
                                HStack(alignment: .center, spacing: 0) {
                                    Text(" \(workoutSet.reps)")
                                        .font(.custom("GochiHand-Regular", size: 36))
    //                                Spacer() ❔ Optional...
                                    Text(" | ")
                                        .font(.custom("GochiHand-Regular", size: 36))
                                        .opacity(0.8)
    //                                Spacer() ❔ Optional...
                                    Text("\(workoutSet.weight) ").foregroundColor(workoutSet.incomplete ? .yellow : .green)
                                        .font(.custom("GochiHand-Regular", size: 30))
                                }
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
            // Graph of the weight progression
            AverageWeightView(data: workoutManager.weightHistory(for: workout.name ?? "Unknown"))
        }
        .onDisappear {
            self.onDisappear()
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
        let workoutManager = PreviewManager.mockWorkoutManager()
        let workout = workoutManager.workouts["Legs"]!.first!

        return ScannedWorkoutView(workout: workout, onDisappear: {})
            .environmentObject(workoutManager)
    }
}
