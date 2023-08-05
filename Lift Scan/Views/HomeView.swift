//
//  HomeView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/3/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var activeSheet: ActiveSheet?
    @State private var scannedCode: String?
    @State private var scannedWorkout: Workout?
    @State private var selectedCategory = ""

    var body: some View {
        NavigationView {
            VStack {
                QRScannerButton(isPresentingScanner: Binding<Bool>(
                    get: { self.activeSheet == .scanner },
                    set: { if $0 { self.activeSheet = .scanner } else { self.activeSheet = nil } }
                ))
                WorkoutCategoryView(selectedCategory: $selectedCategory)
                WorkoutGridView(selectedCategory: $selectedCategory)
                if let scannedWorkout = scannedWorkout {
                    NavigationLink(destination: ScannedWorkoutView(workout: scannedWorkout), isActive: Binding<Bool>(get: { scannedWorkout != nil }, set: { _ in })) {
                        EmptyView()
                    }
                }
            }
            .onChange(of: scannedCode) {
                if let newScannedCode = scannedCode {
                    print("\nNew scanned code: \(scannedCode!)\n")
                    let foundWorkout = self.workoutManager.findWorkout(byCode: newScannedCode)
                    print("Here is the workout found by scanning: \(String(describing: foundWorkout))")
                    if let foundWorkout = foundWorkout {
                        print("FOUND WORKOUT: \(foundWorkout.name ?? "nvm...")")
                        self.scannedWorkout = foundWorkout
                        self.activeSheet = nil
                    } else {
                        self.activeSheet = .newWorkout
                    }
                    scannedCode = nil
                }
            }
            .fullScreenCover(item: $activeSheet) { item in
                switch item {
                case .scanner:
                    QRScannerView { code in
                        scannedCode = code
                    }
                case .newWorkout:
                    NewWorkoutFormView(isPresenting: .constant(false), onComplete: { newWorkout in
                        scannedWorkout = newWorkout
                        activeSheet = nil
                    })
                }
            }
        }
    }
    
    enum ActiveSheet: Identifiable {
        case scanner, newWorkout

        var id: Int {
            hashValue
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let persistentContainer = previewContainer()
        let workoutManager = WorkoutManager(container: persistentContainer)
        let categoryManager = CategoryManager()

        return HomeView()
            .environmentObject(workoutManager)
            .environmentObject(categoryManager)
    }
}
