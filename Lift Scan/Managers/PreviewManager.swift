//
//  PreviewManager.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/4/23.
//

import Foundation
import CoreData

struct PreviewManager {
    
    static func container() -> NSPersistentCloudKitContainer {
        let container = NSPersistentCloudKitContainer(name: "Lift_Scan")
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
        
        return workoutManager
    }
    
    private static func mockWorkoutGenerator(_ name: String, category: String, dayRange: ClosedRange<Int>, workoutManager: WorkoutManager, context: NSManagedObjectContext) -> Void {
        let workout = Workout(context: context)
        workout.name = name
        
        // Creating multiple workoutLogs for the workout
        for day in dayRange {
            let workoutLog = WorkoutLog(context: context)
            let workoutDate = Calendar.current.date(byAdding: .day, value: -day, to: Date())
            workoutLog.date = workoutDate
            
            let weightValues = [100, 110, 115, 120, 125, 130]
            for value in weightValues.prefix(Int.random(in: 1...weightValues.count)) {
                let workoutSet = WorkoutSet(context: context)
                workoutSet.weight = Int16(value)
                workoutSet.reps = Int16.random(in: 5...12)
                workoutSet.date = workoutDate
                workoutLog.addToSets(workoutSet)
            }
            
            workout.addToLogs(workoutLog)
        }

        workoutManager.workouts[category, default: []].append(workout)
    }
}
