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
        print("\n\nSearching for workout by code")
        for categoryWorkouts in workouts.values {
            if let workout = categoryWorkouts.first(where: { workout in
                print(workout.name ?? "Unknown")
                print(workout)
                if let qrCodes = workout.qrCodes?.allObjects as? [QRCode] {
                    for qrCode in qrCodes {
                        print("\(qrCode) == \(qrCode.url ?? "No url")")
                    }
                    let match = qrCodes.contains(where: { $0.url == qrCode })
                    print("Match: \(match)")
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
    
    func createWorkout(name: String, category: String?, color: String?, qrCode: String? = nil, categoryManager: CategoryManager) -> Workout? {
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
        print("🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵")
        print("🔵🔵 QR Code String: \(qrCode ?? "-") 🔵🔵")
        if qrCode != nil && !qrCode!.isEmpty {
            print("🔵🔵 Creating QR Code to assign to workout 🔵🔵")
            let newQrCode: QRCode = QRCode(context: viewContext)
            newQrCode.url = qrCode
            newWorkout.addToQrCodes(newQrCode)
        }
        
        print("🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢")
        print("🟢🟢 Workout qrCodes: \(String(describing: newWorkout.qrCodes)) 🟢🟢") // Debug line

        updateCloud(errorMessage: "Failed to save workout")
        
        return newWorkout
    }

    func removeCustomWorkouts() {
        for categoryWorkouts in workouts.values {
            for workout in categoryWorkouts where workout.qrCodes?.count == 0 {
                // Remove workoutLogs associated with this workout
                if let workoutLogs = workout.logs as? Set<NSManagedObject> {
                    for log in workoutLogs {
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
                if let workoutLogs = workout.logs as? Set<NSManagedObject> {
                    for log in workoutLogs {
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
        if let weights = log.weights as? Set<Weight> {
            for weight in weights {
                viewContext.delete(weight)
            }
        }
        
        viewContext.delete(log)
        
        updateCloud(errorMessage: "Failed to delete workout log")
    }

    // We will add more methods here for creating and updating workouts
}
