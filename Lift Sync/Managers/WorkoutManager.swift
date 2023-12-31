//
//  WorkoutManager.swift
//  Lift Sync
//
//  Created by Ethan McRae on 8/1/23.
//

import Foundation
import CoreData
import SwiftUI

class WorkoutManager: ObservableObject {
    @Published var workouts: [String: [Workout]] = [:]
    let undefinedCategoryName: String = "QR-Code-Scanned"

    let container: NSPersistentCloudKitContainer
    let viewContext: NSManagedObjectContext

    init(container: NSPersistentCloudKitContainer) {
        self.container = container
        self.viewContext = container.viewContext
        fetchWorkouts()
        self.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    private var mockWorkout: Workout {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Workout", in: viewContext)!
        let workout = Workout(entity: entityDescription, insertInto: nil)
        workout.name = "Mock"
        
        return workout
    }
    
    var allWorkouts: [Workout] {
        return Array(workouts.values).flatMap { $0 }
    }

    private func fetchWorkouts() {
        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()

        do {
            let fetchedWorkouts = try viewContext.fetch(fetchRequest)
            
            // Group the workouts by category
            var workoutDictionary: [String: [Workout]] = [:]
            for workout in fetchedWorkouts {
                let categories = workout.categories?.allObjects as? [Category] ?? []
                // If the workout has no categories, group it under the undefined category
                if categories.isEmpty {
                    workoutDictionary[undefinedCategoryName, default: []].append(workout)
                } else {
                    for category in categories {
                        let categoryName = category.name ?? undefinedCategoryName
                        workoutDictionary[categoryName, default: []].append(workout)
                    }
                }
            }
            
            self.workouts = workoutDictionary
            print("🌟")
            print(self.workouts)
        } catch {
            // Handle the error here
            print("Failed to fetch workouts: \(error)")
        }
    }

    func getWorkout(byCode qrCode: String) -> Workout? {
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
    
    func getWorkout(byName name: String) -> Workout? {
        for categoryWorkouts in workouts.values {
            if let workout = categoryWorkouts.first(where: { $0.name?.lowercased() == name.lowercased() }) {
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
    
    func associateCategory(_ category: Category, to workout: Workout, sync: Bool = true) {
        // Do not duplicate the category reference
        let existingCategories = workout.categories?.allObjects as? [Category] ?? []
        let duplicate = existingCategories.contains(category)
        if !duplicate {
            workout.addToCategories(category)
            
            // Sync with cloud
            if sync {
                updateCloud(errorMessage: "Failed to link workout to category")
            }
        }
    }
    
    func createWorkout(name: String, categoryName: String?, color: String?, qrCode: String? = nil, categoryManager: CategoryManager, barWeight: Int16 = 0) -> Workout {
        // Clean up the name
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if a workout with the same name already exists
        if let existingWorkout = getWorkout(byName: cleanName) {
            // Add a new category if necessary
            if let categoryName = categoryName {
                if let category = categoryManager.getCategory(categoryName) {
                    associateCategory(category, to: existingWorkout, sync: false)
                }
            }
            
            // Associate QR Code with the existing workout if necessary
            if let qrCode = qrCode {
                if !qrCode.isEmpty {
                    createAndAppendQRCode(qrCode, for: existingWorkout, sync: false)
                }
            }
            
            updateCloud(errorMessage: "Failed to update a previously existing workout")
            
            return existingWorkout
        }
        
        // Create the workout
        let newWorkout: Workout = Workout(context: viewContext)
        
        // Associate the category and the new workout together
        if categoryName != nil {
            if let category = categoryManager.getCategory(categoryName!) {
                associateCategory(category, to: newWorkout, sync: false)
                categoryManager.associateWorkout(newWorkout, to: category, sync: false)
            }
        }
        
        // Assign other workout properties
        newWorkout.name = cleanName
        newWorkout.color = color
        newWorkout.barWeight = barWeight
        
        // Look for `WorkoutLog` entities with matching name and assign them to the `.logs` property of the workout
        let fetchRequest: NSFetchRequest<WorkoutLog> = WorkoutLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "workoutName == %@", cleanName)
        if let logs = try? viewContext.fetch(fetchRequest) {
            for log in logs {
                newWorkout.addToLogs(log)
            }
        }
        
        // Create QR Code reference
        if qrCode != nil && !qrCode!.isEmpty {
            let newQrCode: QRCode = QRCode(context: viewContext)
            newQrCode.url = qrCode
            newWorkout.addToQrCodes(newQrCode)
        }

        updateCloud(errorMessage: "Failed to save workout")
        
        return newWorkout
    }
    
    func createLog(for workout: Workout) -> WorkoutLog {
        let workoutLog = WorkoutLog(context: viewContext)
        workoutLog.date = Date()
        workoutLog.workout = workout
        workoutLog.workoutName = workout.name
        workoutLog.barWeight = workout.barWeight
        
        workout.addToLogs(workoutLog)
        return workoutLog
    }
    
    func createAndAppendQRCode(_ url: String, for workout: Workout, sync: Bool = true) {
        let qrCodeEntities = workout.qrCodes?.allObjects as? [QRCode] ?? []
        
        // Exit Early: A QR Code entity with a matching URL already exists
        let exists = qrCodeEntities.contains(where: { $0.url == url })
        if exists { return }
        
        // Create entity
        let qrCode = QRCode(context: viewContext)
        qrCode.url = url
        
        // Associate QRCode with Workout
        workout.addToQrCodes(qrCode)
        
        if sync {
            updateCloud(errorMessage: "Failed to create then append a QR Code to a workout")
        }
    }
    
    func recordSet(reps: Int16, weight: Float, complete: Bool, completionIcon: String, workout: Workout, sync: Bool = true) -> Void {
        // Find a log to relate the new set with
        var log = latestLog(workout: workout) ?? createLog(for: workout)
        
        // Establish whether a new log should be created or not (determined by time)
        if isLatestLogOlderThanThreeHours(latestLog: log) {
            log = createLog(for: workout)
        }
        
        let setEntity = WorkoutSet(context: viewContext)
        setEntity.date = Date()
        setEntity.reps = reps
        setEntity.weight = weight
        setEntity.incomplete = !complete
        log.addToSets(setEntity)
        
        // Create/Associate a CompletionType entity relationship
        updateCompletionType(for: setEntity, icon: completionIcon, sync: false)
        
        if sync {
            updateCloud(errorMessage: "Failed to record new WorkoutSet")
        }
    }
    
    func updateCompletionType(for workoutSet: WorkoutSet, icon: String, sync: Bool = true) {
        // Create a CompletionType entity if it doesn't already exist
        if workoutSet.completionType == nil  {
            let completionType = CompletionType(context: viewContext)
            completionType.name = WorkoutManager.completionIconToName(icon)
            completionType.icon = icon
            completionType.set = workoutSet
            workoutSet.completionType = completionType
        }
        // Otherwise, update the icon on the already existant: CompletionType
        else {
            workoutSet.completionType!.icon = icon
        }
        
        if sync {
            updateCloud(errorMessage: "Failed to update completion type icon")
        }
    }
    
    func updateBarWeight(for workout: Workout, barWeight: Int16, sync: Bool = true) {
        // Do nothing if there was no change
        guard barWeight != workout.barWeight else { return }
        
        // Update workout object
        workout.barWeight = barWeight
        
        // Sync to cloud
        if sync {
            updateCloud(errorMessage: "Failed to update bar weight")
        }
        
    }
    
    func updateLog(_ log: WorkoutLog, date: Date, sync: Bool = true) {
        log.date = date
        
        // Gather all child sets and sort them in chronological order
        let sets = log.sets?.allObjects as? [WorkoutSet] ?? []
        let sortedSets = sets.sorted(by: { $0.date! > $1.date! })
        
        // Update the date of each set
        for (index, set) in sortedSets.enumerated() {
            // Update the date of each child set - keeping the order in place
            set.date = date.addingTimeInterval(TimeInterval(index))
        }
        
        if sync {
            updateCloud(errorMessage: "Failed to update workout log date")
        }
    }
    
    func suggestedWeight(for workout: Workout) -> Float {
        let defaultWeight: Float = 50.0
        guard let latestLog = latestLog(workout: workout), let logDate = latestLog.date else { return defaultWeight }
        
        // Check if the last recorded log for this workout has been within the last hour
        let isRecent: Bool = logDate.timeIntervalSinceNow > -3600
        
        if isRecent {
            return latestSet(workout: workout)?.weight ?? defaultWeight
        } else {
            guard let latestSets = latestLog.sets?.allObjects as? [WorkoutSet] else { return defaultWeight }
            let firstSet = latestSets.min { $0.date! < $1.date! }
            
            return firstSet?.weight ?? defaultWeight
        }
    }
    
    func suggestedReps(for workout: Workout) -> Int16 {
        // TODO: Make this smarter by comparing the most recent 2 sets (if today's set has already started) by copying the previous day's reps.
        // - For example: If yesterday's sets were [10, 11, 12], and today's so far are [10, 11], then the next suggestion would be 12.
        // - Do the same for the weights
        
        let defaultReps: Int16 = 12
        guard let latestLog = latestLog(workout: workout), let logDate = latestLog.date else { return defaultReps }
        
        // Check if the last recorded log for this workout has been within the last hour
        let isRecent: Bool = logDate.timeIntervalSinceNow > -3600
        
        if isRecent {
            return latestSet(workout: workout)?.reps ?? defaultReps
        } else {
            guard let latestSets = latestLog.sets?.allObjects as? [WorkoutSet] else { return defaultReps }
            let firstSet = latestSets.min { $0.date! < $1.date! }
            
            return firstSet?.reps ?? defaultReps
        }
    }
    
    func rename(workout: Workout, to newName: String, sync: Bool = true) {
        // Clean up the name
        let cleanName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Update workout
        workout.name = cleanName
        
        // Update related logs
        for log in workout.logs?.allObjects as? [WorkoutLog] ?? [] {
            log.workoutName = cleanName
        }
        
        if sync {
            updateCloud(errorMessage: "Failed to rename workout")
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
    
    func removeWorkout(_ workout: Workout) {
        let categories = workout.categories?.allObjects as? [Category] ?? []
        
        for category in categories {
            // Disassociate the category and workout from one-another
            category.removeFromWorkouts(workout)
            workout.removeFromCategories(category)
            
            // Double-check if the category exists locally
            if var categoryWorkouts = workouts[category.name!] {
                // Find the workout in the array (based on some identifiable property or object reference)
                if let index = categoryWorkouts.firstIndex(where: { $0.id == workout.id }) {
                    // Remove from in-memory list
                    categoryWorkouts.remove(at: index)
                    workouts[category.name!] = categoryWorkouts
                    
                    // Delete from persistent storage
                    viewContext.delete(workout)
                    do {
                        try viewContext.save()
                    } catch {
                        print("Failed to delete workout from persistent storage: \(error)")
                    }
                }
            }
        }
    }

    func removeWorkoutAndLogs(_ workout: Workout) {
        // Delete Logs
        let workoutLogs = workout.logs?.allObjects as? [WorkoutLog] ?? []
        
        for log in workoutLogs {
            deleteLog(log, sync: false)
        }
        
        // Delete workout
        removeWorkout(workout)
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
    
    func deleteLog(_ log: WorkoutLog, sync: Bool = true) {
        viewContext.delete(log)
        
        if sync {
            updateCloud(errorMessage: "Failed to delete workout log")
        }
    }
    
    func deleteSet(_ set: WorkoutSet, sync: Bool = true) {
        // If removing this entity, will cause the parent structure (log) to be empty, then delete it also
        if let parentSetLogs = set.log?.sets as? Set<WorkoutSet> {
            if parentSetLogs.count == 1 {
                viewContext.delete(set.log!)
            }
        }
        
        viewContext.delete(set)
        
        if sync {
            updateCloud(errorMessage: "Failed to delete workout log")
        }
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
        
        guard let workout = getWorkout(byName: workoutName) else { return [:] }
        
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
        guard let log = latestLog(workoutName: workoutName) else { return nil }
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
    
    func latestSet(workout: Workout) -> WorkoutSet? {
        guard let log = latestLog(workout: workout) else { return nil }
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
        guard let workout = getWorkout(byName: workoutName) else { return nil }

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
    
    func latestLog(workout: Workout) -> WorkoutLog? {
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
}

// Static Properties
extension WorkoutManager {
    static func completionIconToName(_ icon: String) -> String {
        var output: String

        switch icon {
        case "xmark.circle.fill":
            output = "Flop"
        case "checkmark.circle.fill":
            output = "Complete"
        case "flame.fill":
            output = "100%"
        case "eurozonesign.circle.fill":
            output = "Too Easy"
        default:
            output = "Unknown"
        }

        return output
    }
    
    static func completionIconToColor(_ icon: String, darkMode: Bool) -> some ShapeStyle {
        var colors: [Color]

        switch icon {
        case "xmark.circle.fill":
            colors = [
                Color.red,
                darkMode ? Color.purple : Color.purple.darker()!
            ]
        case "checkmark.circle.fill":
            colors = [
                Color.accentColor600,
                Color.accentColor300,
            ]
        case "flame.fill":
            colors = [
                darkMode ? Color.yellow : Color.orange, // The innermost part of the flame
                darkMode ? Color.orange : Color.red,    // The middle part of the flame
                darkMode ? Color.red : Color.red.darker()!       // The outermost part of the flame
            ]
//        case "eurozonesign.circle.fill":
//            colors = [
//                Color.accentColor600,
//                darkMode ? Color.blue : Color.blue.darker()!,
//            ]
        default:
            colors = [
                Color.accentColor600,
                Color.accentColor300,
            ]
        }

        return LinearGradient(
            gradient: Gradient(
                colors: colors
            ),
            startPoint: .top,
            endPoint: .bottom
        )
        .anyShapeStyle()
    }
}

#Preview("Icon Colors") {
    HStack {
        // Dark Mode
        ZStack {
            Color.black
            VStack(spacing: 30) {
                ForEach(["xmark.circle.fill", "checkmark.circle.fill", "flame.fill", "eurozonesign.circle.fill", "", "questionmark.circle.fill"], id: \.self) { icon in
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundStyle(WorkoutManager.completionIconToColor(icon, darkMode: true))
                }
            }
        }
        
        // Light Mode
        ZStack {
            Color.white
            VStack(spacing: 30) {
                ForEach(["xmark.circle.fill", "checkmark.circle.fill", "flame.fill", "eurozonesign.circle.fill", "", "questionmark.circle.fill"], id: \.self) { icon in
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundStyle(WorkoutManager.completionIconToColor(icon, darkMode: false))
                }
            }
        }
    }
}
