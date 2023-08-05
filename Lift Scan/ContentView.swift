//
//  ContentView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/1/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // TODO: Create StatsView file
            Text("Todo")
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let persistentContainer = previewContainer()
        let workoutManager = WorkoutManager(container: persistentContainer)
        let categoryManager = CategoryManager()
        
        // Create Mock Workouts
        let workout1 = Workout(context: workoutManager.viewContext)
        workout1.name = "Seated Rows"
        workout1.color = "#00ffff"
        workout1.category = "Legs"
        
        let workout2 = Workout(context: workoutManager.viewContext)
        workout2.name = "Bench Press"
        workout2.color = "#cc00dd"
        workout2.category = "Legs"
        
        let workout3 = Workout(context: workoutManager.viewContext)
        workout3.name = "Squats"
        workout3.color = "#cc55dd"
        workout3.category = "Legs"
        
        workoutManager.workouts["Legs"] = [workout1, workout2, workout3]

        return ContentView()
            .environmentObject(workoutManager)
            .environmentObject(categoryManager)
    }
}
