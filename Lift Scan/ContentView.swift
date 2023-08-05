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
            
            // TODO: Create SettingsView file
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

        return ContentView()
            .environmentObject(workoutManager)
            .environmentObject(categoryManager)
    }
}
