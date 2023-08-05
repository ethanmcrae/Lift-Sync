//
//  Lift_ScanApp.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/1/23.
//


// ‼️ TODOs ‼️
// - - - - - - - - - - - - - - - - - - - -

// When deleting a category, how do you want to handle all of the CUSTOM workouts that are tied to that category? They wont be able to be tapped on anymore

// - - - - - - - - - - - - - - - - - - - -

import SwiftUI
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate {
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "Lift_Scan")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // Inject the persistent container into the WorkoutManager
    lazy var workoutManager = WorkoutManager(container: persistentContainer)
}

@main
struct LiftScanApp: App {
    let persistentContainer: NSPersistentCloudKitContainer
    @StateObject private var workoutManager: WorkoutManager
    @StateObject private var categoryManager = CategoryManager()

    init() {
        persistentContainer = NSPersistentCloudKitContainer(name: "Lift_Scan")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        let workoutManager = WorkoutManager(container: persistentContainer)
        self._workoutManager = StateObject(wrappedValue: workoutManager)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutManager)
                .environmentObject(categoryManager)
        }
    }
}
