//
//  PreviewManager.swift
//  Lift Sync
//
//  Created by Ethan McRae on 8/4/23.
//

import Foundation
import CoreData

struct PreviewManager {
    
    static func container() -> NSPersistentCloudKitContainer {
        let container = NSPersistentCloudKitContainer(name: "Lift_Sync")
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }
    
    static func mockData() -> [Date: Int] {
        var data: [Date: Int] = [:]
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let daysToSkip = 2
        let totalDaysToShow = 6 // This can be adjusted as needed
        let mockDataDays = 3

        // First, populate every day with a 0 value
        for day in 0..<totalDaysToShow {
            let date = Calendar.current.date(byAdding: .day, value: -day, to: currentDate)!
            let dateString = dateFormatter.string(from: date)
            let dateObject = dateFormatter.date(from: dateString)!
            data[dateObject] = 0
        }

        // Next, overwrite the days where there was a workout with 1
        for index in 0..<mockDataDays {
            let day = index * daysToSkip
            let date = Calendar.current.date(byAdding: .day, value: -day, to: currentDate)!
            let dateString = dateFormatter.string(from: date)
            let dateObject = dateFormatter.date(from: dateString)!
            data[dateObject] = 1
        }
        
        return data
    }
    
    static func mockWorkoutManager() -> WorkoutManager {
        let persistentContainer = container()
        let workoutManager = WorkoutManager(container: persistentContainer)
        let context = persistentContainer.viewContext
        
        mockWorkoutGenerator("Squats", category: "Legs", dayRange: 1...3, workoutManager: workoutManager, context: context)
        mockWorkoutGenerator("Lunges", category: "Legs", dayRange: 1...3, workoutManager: workoutManager, context: context)
        mockWorkoutGenerator("Crunches", category: "Core", dayRange: 0...2, workoutManager: workoutManager, context: context)
        mockWorkoutGenerator("Bench Press", category: "Chest / Tri", dayRange: 5...10, workoutManager: workoutManager, context: context, barWeight: 35)
        mockWorkoutGenerator("Example Workout With a long name 1", category: "Test", dayRange: 0...1, workoutManager: workoutManager, context: context)
        mockWorkoutGenerator("Example Workout With a long name 2", category: "Test", dayRange: 1...2, workoutManager: workoutManager, context: context)
        mockWorkoutGenerator("Example Workout With a long name 3", category: "Test", dayRange: 2...3, workoutManager: workoutManager, context: context)
        mockWorkoutGenerator("Example Workout With a long name 4", category: "Test", dayRange: 5...6, workoutManager: workoutManager, context: context)
        mockWorkoutGenerator("Example Workout With a long name 5", category: "Test", dayRange: 3...4, workoutManager: workoutManager, context: context)
        mockWorkoutGenerator("Example Workout With a long name 6", category: "Test", dayRange: 6...7, workoutManager: workoutManager, context: context)
        mockWorkoutGenerator("Example Workout With a long name 7", category: "Test", dayRange: 18...19, workoutManager: workoutManager, context: context)
        mockWorkoutGenerator("Example Workout With a long name 8", category: "Test", dayRange: 30...31, workoutManager: workoutManager, context: context)
        mockWorkoutGenerator("Example Workout With a long name 9", category: "Test", dayRange: 10...11, workoutManager: workoutManager, context: context)
        mockWorkoutGenerator("Short Name 10", category: "Test", dayRange: 19...20, workoutManager: workoutManager, context: context)
        
        return workoutManager
    }
    
    static func mockCategoryManager(empty: Bool = false) -> CategoryManager {
        let persistentContainer = container()
        let categoryManager = CategoryManager(container: persistentContainer)
        let context = persistentContainer.viewContext
        
        if !empty {
            categoryManager.create("Legs")
            categoryManager.create("Core")
            categoryManager.create("Chest / Tri")
            categoryManager.create("Back / Bic")
            categoryManager.create("Test")
        }
        
        return categoryManager
    }
    
    private static func mockWorkoutGenerator(_ name: String, category: String, dayRange: ClosedRange<Int>, workoutManager: WorkoutManager, context: NSManagedObjectContext, barWeight: Int16 = 0) -> Void {
        let workout = Workout(context: context)
        workout.name = name
        workout.barWeight = barWeight
        
        // Creating multiple workoutLogs for the workout
        for day in dayRange {
            let workoutLog = WorkoutLog(context: context)
            let workoutDate = Calendar.current.date(byAdding: .day, value: -day, to: Date())
            workoutLog.date = workoutDate
            
            let weightValues = [100, 110, 115, 120, 125, 130]
            for value in weightValues.prefix(Int.random(in: 1...weightValues.count)) {
                let workoutSet = WorkoutSet(context: context)
                workoutSet.weight = Float(value)
                workoutSet.reps = Int16.random(in: 5...12)
                workoutSet.date = workoutDate?.addingTimeInterval(Double(value)) // Higher weights will be newer
                workoutLog.addToSets(workoutSet)
            }
            
            workout.addToLogs(workoutLog)
        }

        workoutManager.workouts[category, default: []].append(workout)
    }
    
    static func createMockWorkoutLog() -> WorkoutLog {
        let persistentContainer = container()
        let workoutManager = WorkoutManager(container: persistentContainer)
        let context = persistentContainer.viewContext
        
        let workoutLog = WorkoutLog(context: context)
        workoutLog.barWeight = 0
        workoutLog.date = Date()
        return workoutLog
    }
}
