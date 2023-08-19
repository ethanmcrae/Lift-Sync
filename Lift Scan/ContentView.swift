//
//  ContentView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/1/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let tabHighlightColor = colorScheme == .dark ? Color.white : Color.black
        
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // TODO: Create StatsView file
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .accentColor(tabHighlightColor)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutManager = PreviewManager.mockWorkoutManager()
        let categoryManager = CategoryManager()

        return ContentView()
            .environmentObject(workoutManager)
            .environmentObject(categoryManager)
    }
}
