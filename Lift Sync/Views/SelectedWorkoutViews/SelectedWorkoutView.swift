//
//  SelectedWorkoutView.swift
//  Lift Sync
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
    @State var weight: Float = 50.0
    @State var reps: Int16 = 12
    @State var complete = true
    @State var date = Date()
    @State var completionIcon = "checkmark.circle.fill"
    
    private func formattedWeight(_ weight: Float) -> String {
        return "\(weight.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(weight)) : String(format: "%.1f", weight))"
    }
    
    var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
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
                        .fontWeight(.bold)
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
                        .font(isiPad ? .system(size: 50) : .title)
                        .fontWeight(.bold)
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
                        .font(isiPad ? .title : .title3)
                }
            }
            
            // Logs
            ZStack {
                ScrollView(.vertical) {
                    LazyVStack {
                        let sortedLogs = (workout.logs?.allObjects as? [WorkoutLog] ?? []).sorted {
                            $0.date! > $1.date!
                        }
                        
                        ForEach(Array(sortedLogs.enumerated()), id: \.element) { index, log in
                            WorkoutSetListView(log: log, formattedWeight: formattedWeight, weight: $weight, reps: $reps, complete: $complete, date: $date, completionIcon: $completionIcon, index: index, editMode: $editMode)
                        }
                        Spacer()
                            .frame(height: 130)
                    }
                }
                
                // Creates a transparent-feeling gradient that slightly covers the logs shown at the bottom of the screen.
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.clear, .clear, .background.opacity(0.5)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                
                if editMode == .inactive {
                    VStack {
                        Spacer()
                        
                        Button(action: {
                            showingRecordSetForm = true
                        }) {
                            Label("New Set", systemImage: "square.and.pencil")
                                .font(.system(size: isiPad ? 35 : 25))
                                .foregroundColor(.white.opacity(0.95))
                                .padding(20)
                                .padding(.horizontal, isiPad ? 30: 10)
                                .padding(isiPad ? 30 : 0)
                        }
                        .padding(.bottom, 20)
                        .buttonStyle(.borderedProminent)
                        .shadow(radius: 10, x: 0, y: 5)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.bottom, 20)
                }
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
                withAnimation {
                    editMode = .active
                }
                lastSavedWorkoutName = workout.name ?? "Undefined"
                currentWorkoutName = workout.name ?? "Undefined"
            } else {
                withAnimation {
                    editMode = .inactive
                }
                
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
            NewWorkoutSetFormView(isPresented: $showingRecordSetForm, weight: $weight, reps: $reps, complete: $complete, selectedForDeletion: Binding<Bool>(get: { false }, set: { _ in }), completionIcon: $completionIcon, update: false, onPrimary: {
                print("Recording: \(reps) x \(weight)")
                workoutManager.recordSet(reps: reps, weight: weight, complete: complete, completionIcon: completionIcon, workout: workout)
            }, onSecondary: {})
            .presentationDetents([.height(450), .height(550)])
            .onAppear {
                weight = workoutManager.suggestedWeight(for: workout)
                reps = workoutManager.suggestedReps(for: workout)
                complete = true
                completionIcon = "checkmark.circle.fill"
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
    @State var log: WorkoutLog
    let formattedWeight: (Float) -> String
    @Binding var weight: Float
    @Binding var reps: Int16
    @Binding var complete: Bool
    @Binding var date: Date
    @Binding var completionIcon: String
    let index: Int
    @Binding var editMode: EditMode
    
    @State var showingDateForm = false
    
    func deleteWorkoutSet(at offsets: IndexSet) {
        for index in offsets {
            let workoutSetToDelete = (log.sets?.allObjects as? [WorkoutSet] ?? []).sorted(by: { ($0.date ?? Date()) < ($1.date ?? Date()) })[index]
            workoutManager.deleteSet(workoutSetToDelete)
        }
    }
    
    var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        LazyVStack {
            HStack {
                if let logDate = log.date {
                    if editMode == .active {
                        Button(action: {
                            date = logDate
                            showingDateForm.toggle()
                        }) {
                            HStack {
                                Image(systemName: "calendar")
                                Text(logDate, style: .date)
                                    .font(isiPad ? .title2 : .headline)
                                    .fontWeight(isiPad ? .semibold : .medium)
                                    .opacity(0.8)
                            }
                        }
                        .buttonStyle(.bordered)
                        .accentColor(.backgroundInverted)
                    } else {
                        Text(logDate, style: .date)
                            .font(isiPad ? .title2 : .headline)
                            .fontWeight(isiPad ? .semibold : .medium)
                            .opacity(0.8)
                    }
                } else {
                    Text("Unknown Date")
                        .font(.headline)
                        .opacity(0.8)
                }
                Spacer()
                if index == 0 && editMode == .inactive {
                    Text("Performance")
                        .font(isiPad ? .title3 : .subheadline)
                        .fontWeight(isiPad ? .semibold : .medium)
                        .opacity(0.8)
                }
            }
            .padding(.trailing, 4)
            .padding(.top, 10)
            
            VStack {
                let sortedWorkoutSets: [WorkoutSet] = (log.sets?.allObjects as? [WorkoutSet] ?? []).sorted(by: { ($0.date ?? Date()) < ($1.date ?? Date()) })
                
                ForEach(Array(sortedWorkoutSets.enumerated()), id: \.element) { selfIndex, workoutSet in
                    WorkoutSetRow(workoutSet: workoutSet, formattedWeight: formattedWeight, weight: $weight, reps: $reps, complete: $complete, date: $date, completionIcon: $completionIcon, parentIndex: index, selfIndex: selfIndex, editMode: $editMode) {
                        workoutManager.deleteSet(workoutSet)
                    }
                }
            }
        }
        .sheet(isPresented: $showingDateForm, content: {
            UpdateWorkoutDateForm(isPresented: $showingDateForm, date: $date, log: $log)
            .presentationDetents([.height(640), .height(740)])
        })
    }
}

struct WorkoutSetRow: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var showingDeleteAlert = false
    @State var selectedForDeletion = false
    let workoutSet: WorkoutSet
    let formattedWeight: (Float) -> String
    @Binding var weight: Float
    @Binding var reps: Int16
    @Binding var complete: Bool
    @Binding var date: Date
    @Binding var completionIcon: String
    let parentIndex: Int
    let selfIndex: Int
    @Binding var editMode: EditMode
    let onDelete: () -> Void
    
    @State var showingRecordAdjustForm = false
    
    // Pulse animation
    @State var pulse = false
    
    var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var defaultColor: Color {
       Color("BackgroundColor-400").opacity(0.5 + max(0, 0.5 - Double(parentIndex) * 0.15))
    }
    
    var backgroundColor: Color {
        if selectedForDeletion {
            return Color.red.opacity(0.25)
        } else {
            return defaultColor
        }
    }
    
    var body: some View {
        ZStack {
            RowContent
            
            HStack {
                Spacer()
                if let icon = workoutSet.completionType?.icon {
                    Image(systemName: icon)
                        .font(isiPad ? .title : .title2)
                        .foregroundStyle(WorkoutManager.completionIconToColor(icon, darkMode: colorScheme == .dark))
                        .onLongPressGesture(perform: {
                            showingRecordAdjustForm.toggle()
                        })
                } else {
                    if workoutSet.incomplete {
                        Image(systemName: "xmark.circle.fill")
                            .font(isiPad ? .title : .title2)
                            .foregroundStyle(Color.orange)
                            .onLongPressGesture(perform: {
                                showingRecordAdjustForm.toggle()
                            })
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(isiPad ? .title : .title2)
                            .foregroundStyle(Color("AccentColor-400"))
                            .onLongPressGesture(perform: {
                                showingRecordAdjustForm.toggle()
                            })
                    }
                }
            }
        }
        .padding()
        .background(backgroundColor)
        .overlay(pulsingOverlay)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .sheet(isPresented: $showingRecordAdjustForm, content: {
            NewWorkoutSetFormView(isPresented: $showingRecordAdjustForm, weight: $weight, reps: $reps, complete: $complete, selectedForDeletion: $selectedForDeletion, completionIcon: $completionIcon, update: true, onPrimary: {
                workoutSet.weight = weight
                workoutSet.reps = reps
                workoutSet.incomplete = !complete
                workoutManager.updateCompletionType(for: workoutSet, icon: completionIcon, sync: false)
                workoutManager.updateCloud(errorMessage: "Failed to update WorkoutSet")
            }, onSecondary: onDelete)
            .presentationDetents([.height(450), .height(550)])
            .onAppear {
                weight = workoutSet.weight
                reps = workoutSet.reps
                complete = !workoutSet.incomplete
                completionIcon = workoutSet.completionType?.icon ?? (complete ? "checkmark.circle.fill" : "xmark.circle.fill")
            }
        })
    }
    
    var RowContent: some View {
        HStack {
            Button(action: {
                if editMode == .active {
                    showingRecordAdjustForm.toggle()
                }
            }) {
                HStack(spacing: 2) {
                    Text(formattedWeight(workoutSet.weight))
                        .font(isiPad ? .system(size: 40) : .title) // Weight
                    Text("lb")
                        .font(.subheadline)
                        .opacity(0.7) // Unit
                    Text(" x ")
                        .font(isiPad ? .system(size: 30) : .title2).opacity(0.7)
                        .fontWeight(isiPad ? .medium : .bold) // Multiplier
                    Text(" \(workoutSet.reps) ")
                        .font(isiPad ? .system(size: 40) :.title) // Reps
                }
            }
            .disabled(editMode == .inactive)
            .onLongPressGesture(perform: {
                showingRecordAdjustForm.toggle()
            })
            Spacer()
        }
        .foregroundStyle(Color("BackgroundInvertedColor"))
    }
    
    var pulsingOverlay: some View {
        if selectedForDeletion {
            return AnyView(RoundedRectangle(cornerRadius: 10).fill(Color.red.opacity(0.25)))
        }
        
        let isPulseIcon = workoutSet.completionType?.icon == "flame.fill"
        
        return AnyView(
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(
                            colors: isPulseIcon ? [
                                colorScheme == .dark
                                    ? Color.accentColor.opacity(pulse ? 0.25 : 0.10)
                                    : Color.accentColor.opacity(pulse ? 0.20 : 0.05),
                                .clear,
                                .clear,
                                .clear,
                                
                                colorScheme == .dark
                                    ? Color.accentColor.opacity(pulse ? 0.25 : 0.10)
                                    : Color.accentColor.opacity(pulse ? 0.20 : 0.05),
                                colorScheme == .dark
                                ? Color.accentColor.opacity(pulse ? 0.75 : 0.50)
                                    : Color.accentColor.opacity(pulse ? 0.50 : 0.30),
                            ] : [.clear]
                        ),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .opacity(0.25)
                )
                .allowsHitTesting(false)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                        pulse.toggle()
                    }
                }
        )
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

#Preview("Bench Press") {
    let workoutManager = PreviewManager.mockWorkoutManager()
    @State var workout = workoutManager.workouts["Chest / Tri"]!.first!

    return SelectedWorkoutView(workout: $workout, onDisappear: {})
        .environmentObject(workoutManager)
}
