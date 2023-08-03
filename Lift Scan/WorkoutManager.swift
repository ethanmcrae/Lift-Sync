//
//  WorkoutManager.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/1/23.
//

import Foundation
import CoreData

class WorkoutManager: ObservableObject {
    @Published var workouts: [String: [Workout]] = [:]

    private let container: NSPersistentCloudKitContainer

    init() {
        self.container = NSPersistentCloudKitContainer(name: "Lift_Scan")
        fetchWorkouts()
    }

    private func fetchWorkouts() {
        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()

        do {
            let fetchedWorkouts = try container.viewContext.fetch(fetchRequest)
            // Group the workouts by category
            self.workouts = Dictionary(grouping: fetchedWorkouts) { $0.category! }
        } catch {
            // Handle the error here
            print("Failed to fetch workouts: \(error)")
        }
    }

    func findWorkout(by qrCode: String) -> Workout? {
        // Assume that QR codes are unique
        for categoryWorkouts in workouts.values {
            if let workout = categoryWorkouts.first(where: { workout in
                if let qrCodes = workout.qrCodes?.allObjects as? [QRCode] {
                    return qrCodes.contains(where: { $0.url == qrCode })
                }
                return false
            }) {
                return workout
            }
        }
        return nil
    }

    // We will add more methods here for creating and updating workouts
}
