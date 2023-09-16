//
//  SelectedWorkoutView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/1/23.
//

import SwiftUI

struct SelectedWorkoutView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var editMode: EditMode = .inactive
    @State var showingRecordSetForm = false
    @Binding var workout: Workout
    var onDisappear: () -> Void
    
    // Edit Mode
    @State var lastSavedWorkoutName = ""
    @State var currentWorkoutName = ""
    @State var barWeight: Int16 = 0
    
    // Alerts
    @State private var activeAlert: ActiveAlert? = nil
    
    // To pass into the "Record Set" form
    @State var weight: Float = 100.0
    @State var reps: Int16 = 12
    @State var complete = true
    
    private func formattedWeight(_ weight: Float) -> String {
        return "\(weight.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(weight)) : String(format: "%.1f", weight))"
    }

    var body: some View {
        VStack {
            // Title
            if editMode == .active { // Edit Mode Title
                ZStack {
                    HStack {
                        Button(action: {
                            activeAlert = .deleteWorkout
                        }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                                .font(.title2)
                        }
                        .padding()
                        Spacer()
                    }
                    
                    TextField("Workout Name...", text: $currentWorkoutName)
                        .multilineTextAlignment(.center)
                        .autocapitalization(.words)
                        .font(.title)
                        .foregroundColor(.primary)
                        .padding(.vertical, 10)
                        .background(Color("BackgroundInvertedColor").opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
//                        .frame(width: 250)
                        .padding(.horizontal, 60)
                }
//                .padding(.bottom, 20)
            } else { // Initial Title (Non-Edit Mode)
                HStack {
                    Text(workout.name ?? "Undefined")
                        .font(.title)
                        .padding(.vertical, 10)
                }
//                .padding(.bottom, 20)
            }
            
            // Bar Weight
            if editMode == .active {
                BarWeightForm(barWeight: $barWeight)
            } else {
                if barWeight != 0 {
                    Text("Bar Weight / Resistance: \(barWeight) lb")
                        .font(.title3)
                }
            }
            
            // Logs
            ZStack {
                ScrollView(.vertical) {
                    LazyVStack {
                        ForEach(Array((workout.logs?.allObjects as? [WorkoutLog] ?? []).enumerated()), id: \.element) { index, log in
                            WorkoutSetListView(log: log, formattedWeight: formattedWeight, weight: $weight, reps: $reps, complete: $complete, index: index, editMode: $editMode)
                        }
                        Spacer()
                            .frame(height: 130)
                    }
                }
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            showingRecordSetForm = true
                        }) {
                            Label("Record Set", systemImage: "plus.circle")
                                .font(.system(size: 25))
                                .foregroundColor(Color("BackgroundInvertedColor"))
                                .padding(20)
                                .padding(.horizontal, 10)
                        }
                        .padding(.bottom, 20)
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.top, 20)
        }
        .onAppear {
            barWeight = workout.barWeight
        }
        .onDisappear {
            self.onDisappear()
        }
        .navigationBarItems(trailing: Button(action: {
            if editMode == .inactive {
                editMode = .active
                lastSavedWorkoutName = workout.name ?? "Undefined"
                currentWorkoutName = workout.name ?? "Undefined"
            } else {
                editMode = .inactive
                
                // We don't want to save a workout without a name
                guard !currentWorkoutName.isEmpty else { return }
                
                // If the workout name changes: save the changes
                if currentWorkoutName != lastSavedWorkoutName {
                    workoutManager.rename(workout: workout, to: currentWorkoutName, sync: false)
                }
                
                // Update the bar weight
                workoutManager.updateBarWeight(for: workout, barWeight: barWeight, sync: false)
                
                // Update cloud of any changes
                workoutManager.updateCloud(errorMessage: "Failed to save workout changes")
            }
        }) {
            Text(editMode == .inactive ? "Edit" : "Done")
        })
        .alert(item: $activeAlert) { alertType in
            switch alertType {
            case .deleteLogs:
                return Alert(
                    title: Text("Also Delete Related Logs?"),
                    primaryButton: .destructive(Text("Yes")) {
                        activeAlert = nil
                        workoutManager.removeWorkoutAndLogs(workout)
                        onDisappear()
                    },
                    secondaryButton: .cancel(Text("No")) {
                        activeAlert = nil
                        workoutManager.removeWorkout(workout)
                        onDisappear()
                    }
                )
            case .deleteWorkout:
                return Alert(
                    title: Text("Delete \(workout.name ?? "Undefined")?"),
                    primaryButton: .destructive(Text("Delete")) {
                        activeAlert = .deleteLogs
                        onDisappear()
                    },
                    secondaryButton: .cancel(Text("Cancel")) {
                        activeAlert = nil
                    }
                )
            }
        }
        .sheet(isPresented: $showingRecordSetForm, content: {
            NewWorkoutSetFormView(isPresented: $showingRecordSetForm, weight: $weight, reps: $reps, complete: $complete, selectedForDeletion: Binding<Bool>(get: { false }, set: { _ in }), update: false, onPrimary: {
                print("Recording: \(reps) x \(weight)")
                workoutManager.recordSet(reps: reps, weight: weight, complete: complete, workout: workout)
                workoutManager.updateCloud(errorMessage: "Failed to record new WorkoutSet")
            }, onSecondary: {})
            .presentationDetents([.height(450), .height(550)])
            .onAppear {
                weight = workoutManager.suggestedWeight(for: workout)
                reps = workoutManager.suggestedReps(for: workout)
                complete = true
                print("Custom weight: \(weight)")
                print("Custom reps: \(reps)")
            }
        })
        .navigationBarBackButtonHidden(editMode == .active)
        .environment(\.editMode, $editMode)
    }
              
    func onAddBarWeight() {
      
    }
              
    func onDeleteBarWeight() {
      
    }
}

struct WorkoutSetListView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    let log: WorkoutLog
    let formattedWeight: (Float) -> String
    @Binding var weight: Float
    @Binding var reps: Int16
    @Binding var complete: Bool
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
                    Text("Complete")
                        .font(.subheadline)
                        .opacity(0.8)
                }
            }
            .padding(.trailing, 4)
            .padding(.top, 10)
            
            VStack {
                let sortedWorkoutSets: [WorkoutSet] = (log.sets?.allObjects as? [WorkoutSet] ?? []).sorted(by: { ($0.date ?? Date()) < ($1.date ?? Date()) })
                
                ForEach(Array(sortedWorkoutSets.enumerated()), id: \.element) { selfIndex, workoutSet in
                    WorkoutSetRow(workoutSet: workoutSet, formattedWeight: formattedWeight, weight: $weight, reps: $reps, complete: $complete, parentIndex: index, selfIndex: selfIndex, editMode: $editMode) {
                        workoutManager.deleteSet(workoutSet)
                    }
                }
            }
        }
    }
}

struct WorkoutSetRow: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var showingDeleteAlert = false
    @State var selectedForDeletion = false
    let workoutSet: WorkoutSet
    let formattedWeight: (Float) -> String
    @Binding var weight: Float
    @Binding var reps: Int16
    @Binding var complete: Bool
    let parentIndex: Int
    let selfIndex: Int
    @Binding var editMode: EditMode
    let onDelete: () -> Void
    
    @State var showingRecordAdjustForm = false
    
    var body: some View {
        ZStack {
            Button(action: {
                if editMode == .active {
                    showingRecordAdjustForm.toggle()
                }
            }) {
                HStack(spacing: 2) {
                    Text(formattedWeight(workoutSet.weight)).font(.title) // Weight
                    Text("lb").font(.subheadline).opacity(0.7) // Unit
                    Text(" x ").font(.title2).opacity(0.7).fontWeight(.heavy) // Multiplier
                    Text(" \(workoutSet.reps) ").font(.title) // Reps
                    Spacer()
                }
                .foregroundStyle(Color("BackgroundInvertedColor"))
            }
            
            HStack {
                Spacer()
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
        .padding()
        .background(selectedForDeletion ? Color.red.opacity(0.25) : Color("BackgroundColor-400").opacity(0.5 + max(0, 0.5 - Double(parentIndex) * 0.15)))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .sheet(isPresented: $showingRecordAdjustForm, content: {
            NewWorkoutSetFormView(isPresented: $showingRecordAdjustForm, weight: $weight, reps: $reps, complete: $complete, selectedForDeletion: $selectedForDeletion, update: true, onPrimary: {
                workoutSet.weight = weight
                workoutSet.reps = reps
                workoutSet.incomplete = !complete
                workoutManager.updateCloud(errorMessage: "Failed to update WorkoutSet")
            }, onSecondary: onDelete)
            .presentationDetents([.height(450), .height(550)])
            .onAppear {
                weight = workoutSet.weight
                reps = workoutSet.reps
                complete = !workoutSet.incomplete
            }
        })
    }
}

enum ActiveAlert: Identifiable {
    case deleteLogs
    case deleteWorkout

    var id: Int {
        switch self {
        case .deleteLogs: return 0
        case .deleteWorkout: return 1
        }
    }
}

struct SelectedWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutManager = PreviewManager.mockWorkoutManager()
        @State var workout = workoutManager.workouts["Chest / Tri"]!.first!

        return SelectedWorkoutView(workout: $workout, onDisappear: {})
            .environmentObject(workoutManager)
    }
}
