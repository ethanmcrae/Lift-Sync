//
//  WorkoutGridView.swift
//  Lift Sync
//
//  Created by Ethan McRae on 8/1/23.
//

import SwiftUI

struct WorkoutGridView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var selectedCategory: String
    var onDisappear: () -> Void
    @Binding var homeTutorialStep: Int
    @State var workout: Workout?
    private func onCreateNewWorkout() -> Void {
        self.workout = nil
    }
    
    var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        VStack {
            ScrollView(.vertical) {
                // Filter out workouts without names
                let unsortedWorkouts = workoutManager.workouts[selectedCategory]?.filter { $0.name != nil } ?? []
                // Sort by latest set
                let sortedWorkouts = unsortedWorkouts.sorted {
                    workoutManager.latestSet(workout: $0)?.date! ?? Date() > workoutManager.latestSet(workout: $1)?.date! ?? Date()
                }
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: isiPad ? 3 : 2), spacing: 15) {
                    ForEach(sortedWorkouts) { workout in
                        let backgroundOpacity = opacityBasedOnDate(workoutManager.latestSet(workout: workout)?.date ?? Date())
                        
                        NavigationLink(destination: SelectedWorkoutView(workout: Binding<Workout>(get: { workout }, set: { _ in }), onDisappear: onDisappear)
                            .environmentObject(workoutManager)) {
                                Text(workout.name ?? "Unknown")
                                    .font(isiPad ? .title : .title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color("BackgroundColor-300"))
                                    .padding(20)
                                    .padding(.vertical, isiPad ? 10 : 0)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .shadow(color: Color.accent.opacity(0.2), radius: 10)
                                    .background(Color("BackgroundInvertedColor").gradient.opacity(backgroundOpacity))
                                    .cornerRadius(8)
                                    .shadow(color: Color.accentColor400.opacity(0.25), radius: 15, x: 10, y: 10)
                            }
                    }
                }
                .padding(.bottom, 30)
                .padding()
            }
            .frame(maxHeight: .infinity)
            .mask(
                LinearGradient(
                    gradient: Gradient(colors: [.white, .white, .white.opacity(0.5)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            if !selectedCategory.isEmpty {
                // Add new button
                Spacer()
                NavigationLink(destination: NewWorkoutFormView(isPresenting: .constant(false), qrCode: nil, onComplete: { newWorkout in
                    self.workout = newWorkout
                }, category: $selectedCategory)) {
                    HStack(alignment: .center, spacing: 2) {
                        Image(systemName: "plus.circle")
                            .font(isiPad ? .system(size: 35) : .title2)
                            .foregroundColor(.white.opacity(0.95))
                        Text("Add Workout")
                            .font(isiPad ? .system(size: 35) : .title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.95))
                            .padding(20)
                            .padding(.vertical, isiPad ? 30 : 0)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
//                    .shadow(color: Color("LightColor"), radius: 10)
                    .background(Color("AccentColor"))
                    .cornerRadius(10)
                    .shadow(color: Color(.black).opacity(0.75), radius: 10, x: 5, y: 10)
                    .popover(isPresented: TutorialManager.isShowingPopover(TutorialManager.Tutorial.home, currentStep: $homeTutorialStep, expected: 6)) {
                        TutorialHomePopup(text: "Create your first workout here", step: $homeTutorialStep, tutorial: TutorialManager.Tutorial.home)
                    }
                }
                
                if self.workout != nil {
                    NavigationLink(destination: SelectedWorkoutView(workout: Binding<Workout>(get: { self.workout! }, set: { newValue in self.workout = newValue }), onDisappear: self.onCreateNewWorkout), isActive: Binding<Bool>(get: { true }, set: { _ in })) {
                        EmptyView()
                    }
                }
            } else {
                Text("Select a workout category above...")
                    .font(isiPad ? .title : .title3)
                Spacer()
                    .frame(height: 300)
            }
        }
        .frame(maxHeight: .infinity)
    }
}

func opacityBasedOnDate(_ date: Date) -> Double {
    let currentDate = Date()
    let dayInSeconds: TimeInterval = 86400 // 24 hours * 60 minutes * 60 seconds
    let thirtyDaysInSeconds = 30 * dayInSeconds
    
    // Calculate the difference in seconds between the two dates
    let differenceInSeconds = currentDate.timeIntervalSince(date)
    
    // If the date is in the future, return 100% opacity
    guard differenceInSeconds >= 0 else { return 1.0 }
    
    // If the difference is 30 days or more, return 50% opacity
    guard differenceInSeconds < thirtyDaysInSeconds else { return 0.5 }
    
    // Calculate a linear interpolation between 1.0 and 0.5 based on the difference
    let proportion = differenceInSeconds / thirtyDaysInSeconds
    let opacity = 1.0 - (0.5 * proportion)
    
    return opacity
}

#Preview {
    @State var selectedCategory = "Test"
    @State var homeTutorialStep = 5
    let workoutManager = PreviewManager.mockWorkoutManager()
    let categoryManager = PreviewManager.mockCategoryManager()

    return ZStack {
        VStack {
            Color("AccentColor-600")
            Color("BackgroundColor")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        VStack {
            Spacer()
                .frame(maxHeight: .infinity)
            WorkoutGridView(selectedCategory: $selectedCategory, onDisappear: {}, homeTutorialStep: $homeTutorialStep)
                .environmentObject(workoutManager)
                .environmentObject(categoryManager)
        }
    }
}

#Preview("Unselected Category") {
    @State var selectedCategory = ""
    @State var homeTutorialStep = 5
    let workoutManager = PreviewManager.mockWorkoutManager()
    let categoryManager = PreviewManager.mockCategoryManager()

    return ZStack {
        VStack {
            Color("AccentColor-600")
            Color("BackgroundColor")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        VStack {
            Spacer()
                .frame(maxHeight: .infinity)
            WorkoutGridView(selectedCategory: $selectedCategory, onDisappear: {}, homeTutorialStep: $homeTutorialStep)
                .environmentObject(workoutManager)
                .environmentObject(categoryManager)
        }
    }
}
