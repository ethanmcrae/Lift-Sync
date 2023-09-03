//
//  WorkoutManager.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/1/23.
//

import Foundation
import CoreData
import SwiftUI

class WorkoutManager: ObservableObject {
    @Published var workouts: [String: [Workout]] = [:]

    let container: NSPersistentCloudKitContainer
    let viewContext: NSManagedObjectContext

    init(container: NSPersistentCloudKitContainer) {
        self.container = container
        self.viewContext = container.viewContext
        fetchWorkouts()
        self.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    var allWorkouts: [Workout] {
        return Array(workouts.values).flatMap { $0 }
    }

    private func fetchWorkouts() {
        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()

        do {
            let fetchedWorkouts = try viewContext.fetch(fetchRequest)
            // Group the workouts by category
            self.workouts = Dictionary(grouping: fetchedWorkouts) { $0.category ?? "QR-Code-Scanned" }
        } catch {
            // Handle the error here
            print("Failed to fetch workouts: \(error)")
        }
    }

    func findWorkout(byCode qrCode: String) -> Workout? {
        for categoryWorkouts in workouts.values {
            if let workout = categoryWorkouts.first(where: { workout in
                if let qrCodes = workout.qrCodes?.allObjects as? [QRCode] {
                    let match = qrCodes.contains(where: { $0.url == qrCode })
                    return match
                }
                return false
            }) {
                return workout
            }
        }
        return nil
    }
    
    func findWorkout(byName name: String) -> Workout? {
        for categoryWorkouts in workouts.values {
            if let workout = categoryWorkouts.first(where: { $0.name == name }) {
                return workout
            }
        }
        return nil
    }
    
    func updateCloud(errorMessage: String) {
        do {
            try viewContext.save()
            fetchWorkouts()
        } catch {
            // Handle the error here
            print("\(errorMessage): \(error)")
        }
    }
    
    func createWorkout(name: String, category: String?, color: String?, qrCode: String? = nil, categoryManager: CategoryManager?) -> Workout {
        // Check if a workout with the same name already exists
        if let existingWorkout = findWorkout(byName: name) {
            return existingWorkout
        }
        
        // Create the workout
        let newWorkout: Workout = Workout(context: viewContext)
        newWorkout.name = name
        newWorkout.category = category
        newWorkout.color = color
        
        // Create QR Code reference
        if qrCode != nil && !qrCode!.isEmpty {
            let newQrCode: QRCode = QRCode(context: viewContext)
            newQrCode.url = qrCode
            newWorkout.addToQrCodes(newQrCode)
        }

        updateCloud(errorMessage: "Failed to save workout")
        
        return newWorkout
    }
    
    func createLog(workout: Workout) -> WorkoutLog {
        let workoutLog = WorkoutLog(context: viewContext)
        workoutLog.date = Date()
        workoutLog.workout = workout
        workoutLog.barWeight = workout.barWeight
        return workoutLog
    }
    
    func recordSet(reps: Int16, weight: Float, complete: Bool = true, workout: Workout) -> Void {
        guard let workoutName = workout.name else { return }
        
        // Find a log to relate the new set with
        if var log = latestLog(workoutName: workoutName) {
            // Establish whether a new log should be created or not (determined by time)
            if isLatestLogOlderThanThreeHours(latestLog: log) {
                log = createLog(workout: workout)
            }
            
            let setEntity = WorkoutSet(context: viewContext)
            setEntity.date = Date()
            setEntity.weight = Float(weight)
            setEntity.incomplete = !complete
            log.addToSets(setEntity)
        }
    }

    func removeCustomWorkouts() {
        for categoryWorkouts in workouts.values {
            for workout in categoryWorkouts where workout.qrCodes?.count == 0 {
                // Remove workoutLogs associated with this workout
                if let workoutLogs = workout.logs as? Set<WorkoutLog> {
                    for log in workoutLogs {
                        if let workoutSets = log.sets as? Set<WorkoutSet> {
                            for workoutSet in workoutSets {
                                viewContext.delete(workoutSet as WorkoutSet)
                            }
                        }
                        viewContext.delete(log as NSManagedObject)
                    }
                }
                viewContext.delete(workout)
            }
        }
        updateCloud(errorMessage: "Failed to remove custom workouts")
    }

    func removeAllWorkouts() {
        for categoryWorkouts in workouts.values {
            for workout in categoryWorkouts {
                // Remove workoutLogs associated with this workout
                if let workoutLogs = workout.logs as? Set<WorkoutLog> {
                    for log in workoutLogs {
                        if let workoutSets = log.sets as? Set<WorkoutSet> {
                            for workoutSet in workoutSets {
                                viewContext.delete(workoutSet as WorkoutSet)
                            }
                        }
                        viewContext.delete(log as NSManagedObject)
                    }
                }
                viewContext.delete(workout)
            }
        }
        updateCloud(errorMessage: "Failed to remove all workouts")
    }
    
    func deleteLog(_ log: WorkoutLog) {
        // Remove weights associated with this workout log
        if let workoutSets = log.sets as? Set<WorkoutSet> {
            for workoutSet in workoutSets {
                viewContext.delete(workoutSet)
            }
        }
        
        viewContext.delete(log)
        
        updateCloud(errorMessage: "Failed to delete workout log")
    }
    
    func deleteSet(_ set: WorkoutSet) {
        viewContext.delete(set)
        
        // If after removing this entity, the parent structure (log) is now empty, then delete it also
        if let parentSetLogs = set.log?.sets as? Set<WorkoutSet> {
            if parentSetLogs.isEmpty {
                viewContext.delete(set.log!)
            }
        }
        
        updateCloud(errorMessage: "Failed to delete workout log")
    }

    // Return a dictionary of date and number of workouts on that date
    func workoutsPerDate() -> [Date: Int] {
        var dateWorkouts: [Date: Int] = [:]
        
        // Assuming we want to show data for the past 6 days (including today)
        let daysToShow = 6
        let currentDate = Date()
        
        // Initialize every day with 0 workouts
        for day in 0..<daysToShow {
            let date = Calendar.current.date(byAdding: .day, value: -day, to: currentDate)!
            let dateWithoutTime = Calendar.current.startOfDay(for: date)
            dateWorkouts[dateWithoutTime] = 0
        }
        
        for categoryWorkouts in workouts.values {
            for workout in categoryWorkouts {
                let logs = workout.logs?.allObjects as? [WorkoutLog] ?? []
                for log in logs {
                    // Ignoring time components of date for comparison
                    let dateWithoutTime = Calendar.current.startOfDay(for: log.date ?? Date())
                    dateWorkouts[dateWithoutTime, default: 0] += 1
                }
            }
        }
        
        return dateWorkouts
    }

    // Returns average weight for a given workout over time
    func weightHistory(for workoutName: String) -> [Date: [(reps: Int, weight: Float)]] {
        var weightProgression: [Date: [(reps: Int, weight: Float)]] = [:]
        
        guard let workout = findWorkout(byName: workoutName) else { return [:] }
        
        let logs = workout.logs?.allObjects as? [WorkoutLog] ?? []
        for log in logs {
            guard let workoutSets = log.sets as? Set<WorkoutSet> else { continue }
            guard let workoutDate = log.date else { continue }
            
            var logData: [(reps: Int, weight: Float)] = []
            
            for workoutSet in workoutSets {
                let reps = Int(workoutSet.reps)
                let weight = workoutSet.weight
                logData.append((reps: reps, weight: weight))
            }
            
            weightProgression[workoutDate] = logData
        }
        
        return weightProgression
    }
    
    func latestSet(workoutName: String) -> WorkoutSet? {
        let log = latestLog(workoutName: workoutName) ?? createLog(workout: (findWorkout(byName: workoutName) ?? createWorkout(name: workoutName, category: nil, color: nil, categoryManager: nil)))
        guard let workoutSets = log.sets as? Set<WorkoutSet> else { return nil }
        
        var latestDate: Date? = nil
        var latestSet: WorkoutSet? = nil
        
        for workoutSet in workoutSets {
            guard let date = workoutSet.date else { continue }
            
            // Check if the current set's date is more recent than the stored latest date
            if latestDate == nil || date > latestDate! {
                latestDate = date
                latestSet = workoutSet
            }
        }
        
        return latestSet
    }
    
    func latestLog(workoutName: String) -> WorkoutLog? {
        guard let workout = findWorkout(byName: workoutName) else { return nil }

        var latestDate: Date? = nil
        var latestLog: WorkoutLog? = nil

        let logs = workout.logs?.allObjects as? [WorkoutLog] ?? []
        for log in logs {
            guard let logDate = log.date else { continue }
            
            if latestDate == nil || logDate > latestDate! {
                latestDate = logDate
                latestLog = log
            }
        }

        return latestLog
    }
    
    func isLatestLogOlderThanThreeHours(latestLog: WorkoutLog) -> Bool {
        guard let latestLogDate = latestLog.date else { return false }

        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(latestLogDate)
        let threeHoursInSeconds: TimeInterval = 3 * 60 * 60

        return timeInterval > threeHoursInSeconds
    }
    
    // We will add more methods here for creating and updating workouts
}
