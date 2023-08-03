//
//  ScannedWorkoutView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/1/23.
//

import SwiftUI

struct ScannedWorkoutView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    var scannedCode: String

    var body: some View {
        // We still need to add functionality that will display a simple form that allows you to type what the workout is called and then save it to our DB (or whatever) so we can assign new QR Code URLs to workouts. Only the form will be shown until there is a linked page (workout history data) to the url.
        let workout = workoutManager.findWorkout(by: scannedCode)
        // This is a placeholder. Replace with the actual workout view.
        VStack {
            Text(workout?.name ?? "Undefined")
            // Show workout history here.
        }
    }
}

struct ScannedWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        ScannedWorkoutView(scannedCode: "Example.com")
    }
}
