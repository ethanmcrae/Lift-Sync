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
    @State var workout: Workout?
    private func onCreateNewWorkout() -> Void {
        self.workout = nil
    }

    var body: some View {
        VStack {
            VStack {
                let workouts = workoutManager.workouts[selectedCategory]?.filter { $0.name != nil } ?? []
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                    ForEach(workouts) { workout in
                        let gradientColors: [Color] = [Color("BackgroundColor-300").opacity(0.8), Color("BackgroundColor-300").opacity(0.5)]
                        let gradient = LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .leading, endPoint: .trailing)
                        let mixedColor = workout.color != nil ? Color(hex: workout.color!) ?? Color("AccentAlt-300") : Color("AccentAlt-400")
                        // Complete color products
                        let mainColor = mixedColor.overlay(gradient)
                        let shadowColorColor = mixedColor.darker(by: 0.5) ?? Color(.black).opacity(0.5)
                        let shadowColor = shadowColorColor.opacity(0.15)
                        
                        NavigationLink(destination: SelectedWorkoutView(workout: workout, onDisappear: onDisappear)
                            .environmentObject(workoutManager)) {
                                Text(workout.name ?? "Unknown")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("BackgroundInvertedColor"))
                                    .padding(20)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .shadow(color: Color("BackgroundColor"), radius: 10)
                                    .background(mainColor)
                                    .cornerRadius(10)
                                    .shadow(color: shadowColor, radius: 10, x: 5, y: 10)
                                    .onAppear {
                                        print("🔥 Workout: \(workout)")
                                    }
                            }
                    }
                }
                .padding(.horizontal)
            }
            
            if !selectedCategory.isEmpty {
                // Add new button
                Spacer()
                NavigationLink(destination:                     NewWorkoutFormView(isPresenting: .constant(false), qrCode: nil, onComplete: { newWorkout in
                    self.workout = newWorkout
                }, category: $selectedCategory)) {
                    HStack(alignment: .center, spacing: 2) {
                        Image(systemName: "plus.circle")
                            .font(.title)
                            .foregroundColor(Color("BackgroundInvertedColor"))
                        Text("Add Workout")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("BackgroundInvertedColor"))
                            .padding(20)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .shadow(color: Color("BackgroundColor"), radius: 10)
                    .background(Color("AccentColor"))
                    .cornerRadius(10)
                    .shadow(color: Color(.black).opacity(0.75), radius: 10, x: 5, y: 10)
                    //                .padding(.top, 20)
                }
                
                if let newWorkout = workout {
                    NavigationLink(destination: SelectedWorkoutView(workout: newWorkout, onDisappear: self.onCreateNewWorkout), isActive: Binding<Bool>(get: { newWorkout != nil }, set: { _ in })) {
                        EmptyView()
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}

struct WorkoutGridView_Previews: PreviewProvider {
    static var previews: some View {
        @State var selectedCategory = "Legs"
        let workoutManager = PreviewManager.mockWorkoutManager()
        let categoryManager = CategoryManager()

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
                WorkoutGridView(selectedCategory: $selectedCategory, onDisappear: {})
                    .environmentObject(workoutManager)
                    .environmentObject(categoryManager)
            }
        }
    }
}
