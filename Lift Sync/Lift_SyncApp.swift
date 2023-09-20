//
//  Lift_ScanApp.swift
//  Lift Sync
//
//  Created by Ethan McRae on 8/1/23.
//


// ‼️ TODOs ‼️
// - - - - - - - - - - - - - - - - - - - -

// ...

// - - - - - - - - - - - - - - - - - - - -

// 🚀 Version 2 🚀
// - - - - - - - - - - - - - - - - - - - -

// 1️⃣ Feature:
// Your muscles tire out throughout the workout. So, the weights will only be somewhat helpful if the order of workouts change.
// - Introducing: Workout Programs. You can create a program to include an ordered set of workouts. When showing your weight logs, the logs matching the same program will be highlighted.
// - Make a bigger shift toward using a program. Perhaps the main button on the home screen can be "Choose Program" with a secondary button "No Program" underneath (that would take you to see v1's home screen basically).
//   - Stretch: Share with friends?
//   - Stretch: Auto suggest based on patterns. Example: (80% of mondays == leg day; display leg day)

// 2️⃣ New App:
// Pair a watch app with the app for easier/faster logging.

// 3️⃣ Feature:
// Add friend sync for workout buddies.

// - - - - - - - - - - - - - - - - - - - -

import SwiftUI
import CoreData

@main
struct LiftSyncApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistentContainer: NSPersistentCloudKitContainer
    @StateObject private var workoutManager: WorkoutManager
    @StateObject private var categoryManager: CategoryManager

    init() {
        persistentContainer = NSPersistentCloudKitContainer(name: "Lift_Scan")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true

        let workoutManager = WorkoutManager(container: persistentContainer)
        self._workoutManager = StateObject(wrappedValue: workoutManager)
        
        let categoryManager = CategoryManager(container: persistentContainer)
        self._categoryManager = StateObject(wrappedValue: categoryManager)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutManager)
                .environmentObject(categoryManager)
        }
    }
}

// Force Portrait Orientation
class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
