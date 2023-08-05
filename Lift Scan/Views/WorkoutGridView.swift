//
//  WorkoutGridView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/1/23.
//

import SwiftUI

struct WorkoutGridView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var selectedCategory: String
    var onDisappear: () -> Void

    var body: some View {
        let workouts = workoutManager.workouts[selectedCategory]?.filter { $0.name != nil } ?? []
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
            ForEach(workouts) { workout in
                NavigationLink(destination: ScannedWorkoutView(workout: workout, onDisappear: onDisappear)
                    .environmentObject(workoutManager)) {
                        Text(workout.name ?? "Unknown")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(20)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color(hex: workout.color ?? "cc00dd"))
                            .cornerRadius(15)
                    .onAppear {
                        print("🔥 Workout: \(workout)")
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct WorkoutGridView_Previews: PreviewProvider {
    static var previews: some View {
        @State var selectedCategory = "Legs"
        let persistentContainer = previewContainer()
        let workoutManager = WorkoutManager(container: persistentContainer)
        let categoryManager = CategoryManager()
        
        // Create Mock Workouts
        let workout1 = Workout(context: workoutManager.viewContext)
        workout1.name = "Seated Rows"
        workout1.color = "#00ffff"
        workout1.category = selectedCategory
        
        let workout2 = Workout(context: workoutManager.viewContext)
        workout2.name = "Bench Press"
        workout2.color = "#cc00dd"
        workout2.category = selectedCategory
        
        let workout3 = Workout(context: workoutManager.viewContext)
        workout3.name = "Squats"
        workout3.color = "#cc55dd"
        workout3.category = selectedCategory
        
        workoutManager.workouts[selectedCategory] = [workout1, workout2, workout3]

        return ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            WorkoutGridView(selectedCategory: $selectedCategory, onDisappear: {})
                .environmentObject(workoutManager)
                .environmentObject(categoryManager)
        }
    }
}
