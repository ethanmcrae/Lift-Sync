//
//  SelectedWorkoutView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/1/23.
//

import SwiftUI

struct SelectedWorkoutView: View {
    @State private var editMode: EditMode = .inactive
    var workout: Workout
    var onDisappear: () -> Void
    
    private func formattedWeight(_ weight: Float) -> String {
        return "\(weight.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(weight)) : String(format: "%.1f", weight))"
    }

    var body: some View {
        VStack {
            // Title
            Text(workout.name ?? "Removed")
                .font(.title)
                .padding(.bottom, 20)
            
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(Array((workout.logs?.allObjects as? [WorkoutLog] ?? []).enumerated()), id: \.element) { index, log in
                        WorkoutSetListView(log: log, formattedWeight: formattedWeight, index: index, editMode: $editMode)
                    }
                }
            }
            .padding(.bottom)
        }
        .onDisappear {
            self.onDisappear()
        }
        .navigationBarItems(trailing: Button(action: {
            if editMode == .inactive {
                editMode = .active
            } else {
                editMode = .inactive
            }
        }) {
            Text(editMode == .inactive ? "Edit" : "Cancel")
        })
        .environment(\.editMode, $editMode)
    }
}

struct WorkoutSetListView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    let log: WorkoutLog
    let formattedWeight: (Float) -> String
    let index: Int
    @Binding var editMode: EditMode
    
    func deleteWorkoutSet(at offsets: IndexSet) {
        for index in offsets {
            let workoutSetToDelete = (log.sets?.allObjects as? [WorkoutSet] ?? []).sorted(by: { ($0.date ?? Date()) < ($1.date ?? Date()) })[index]
            workoutManager.deleteSet(workoutSetToDelete)
        }
    }
    
    var body: some View {
        LazyVStack {
            HStack {
                if let date = log.date {
                    Text(date, style: .date)
                        .font(.headline)
                        .opacity(0.8)
                } else {
                    Text("Unknown Date")
                        .font(.headline)
                        .opacity(0.8)
                }
                Spacer()
                if index == 0 {
                    Text(editMode == .inactive ? "Complete" : "Remove")
                        .font(.subheadline)
                        .opacity(0.8)
                }
            }
            .padding(.trailing, 4)
            .padding(.top, 10)
            
            VStack {
                let sortedWorkoutSets: [WorkoutSet] = (log.sets?.allObjects as? [WorkoutSet] ?? []).sorted(by: { ($0.date ?? Date()) < ($1.date ?? Date()) })
                
                ForEach(Array(sortedWorkoutSets.enumerated()), id: \.element) { selfIndex, workoutSet in
                    WorkoutSetRow(workoutSet: workoutSet, formattedWeight: formattedWeight, parentIndex: index, selfIndex: selfIndex, editMode: $editMode) {
                        workoutManager.deleteSet(workoutSet)
                    }
                }
            }
        }
    }
}

struct WorkoutSetRow: View {
    @State private var showingDeleteAlert = false
    @State var selectedForDeletion = false
    let workoutSet: WorkoutSet
    let formattedWeight: (Float) -> String
    let parentIndex: Int
    let selfIndex: Int
    @Binding var editMode: EditMode
    let onDelete: () -> Void
    
    var body: some View {
        ZStack {
            HStack(spacing: 2) {
                Text(formattedWeight(workoutSet.weight)).font(.title) // Weight
                Text("lb").font(.subheadline).opacity(0.7) // Unit
                Text(" x ").font(.title2).opacity(0.7).fontWeight(.heavy) // Multiplier
                Text(" \(workoutSet.reps) ").font(.title) // Reps
                Spacer()
            }
            
            HStack {
                Spacer()
                if editMode == .active {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.red)
                } else {
                    if workoutSet.incomplete {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.orange)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color("AccentColor-400"))
                    }
                }
            }
        }
        .padding()
        .background(selectedForDeletion ? Color.red.opacity(0.25) : Color("BackgroundColor-400").opacity(0.5 + max(0, 0.5 - Double(parentIndex) * 0.15)))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
            if editMode == .active {
                selectedForDeletion = true
                showingDeleteAlert = true
            }
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete workout log?"),
                message: Text("Are you sure you want to delete this workout log? This cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    withAnimation {
                        onDelete()
                    }
                },
                secondaryButton: .cancel() {
                    withAnimation {
                        selectedForDeletion = false
                    }
                }
            )
        }
    }
}

struct SelectedWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutManager = PreviewManager.mockWorkoutManager()
        let workout = workoutManager.workouts["Legs"]!.first!

        return SelectedWorkoutView(workout: workout, onDisappear: {})
            .environmentObject(workoutManager)
    }
}
