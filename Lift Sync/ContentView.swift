//
//  ContentView.swift
//  Lift Sync
//
//  Created by Ethan McRae on 8/1/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var isActive: Bool = false
    let version = 1.0
    
    var body: some View {
        ZStack {
            if self.isActive {
                if version == 1.0 {
                    HomeView()
                } else if version == 1.1 {
                    let tabHighlightColor = colorScheme == .dark ? Color.white : Color.black
                    TabView {
                        HomeView()
                            .tabItem {
                                Label("Home", systemImage: "house.fill")
                            }
                            .accentColor(Color("AccentColor"))
                        
                        StatsView()
                            .tabItem {
                                Label("Stats", systemImage: "chart.bar.fill")
                            }
                            .accentColor(Color("AccentColor"))
                        
                        SettingsView()
                            .tabItem {
                                Label("Settings", systemImage: "gearshape.fill")
                            }
                            .accentColor(Color("AccentColor"))
                    }
                    .accentColor(tabHighlightColor)
                }
            } else {
                SplashView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutManager = PreviewManager.mockWorkoutManager()
        let categoryManager = PreviewManager.mockCategoryManager()

        return ContentView()
            .environmentObject(workoutManager)
            .environmentObject(categoryManager)
    }
}
