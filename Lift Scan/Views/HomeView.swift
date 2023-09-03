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
    @State private var selectedWorkout: Workout?
    @State private var selectedCategory = ""
    @State private var previousScannedCode = ""
    
    private func onDisappear() -> Void {
        self.selectedWorkout = nil
    }

    var body: some View {
        NavigationView {
            VStack {
                QRScannerButton(isPresentingScanner: Binding<Bool>(
                    get: { self.activeSheet == .scanner },
                    set: { if $0 { self.activeSheet = .scanner } else { self.activeSheet = nil } }
                ))
                ZStack {
                    Color("BackgroundColor")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        WorkoutCategoryView(selectedCategory: $selectedCategory)
                        WorkoutGridView(selectedCategory: $selectedCategory, onDisappear: self.onDisappear)
                        Spacer()
                    }
                }
                if let selectedWorkout = selectedWorkout {
                    NavigationLink(destination: SelectedWorkoutView(workout: selectedWorkout, onDisappear: self.onDisappear), isActive: Binding<Bool>(get: { selectedWorkout != nil }, set: { _ in })) {
                        EmptyView()
                    }
                }
            }
            .fullScreen()
            .backgroundColor(Color("AccentColor-600"))
            .onChange(of: scannedCode) { _ in
                if let newScannedCode = scannedCode {
                    let foundWorkout = self.workoutManager.findWorkout(byCode: newScannedCode)
                    if let foundWorkout = foundWorkout {
                        self.selectedWorkout = foundWorkout
                        self.activeSheet = nil
                    } else {
                        self.activeSheet = .newWorkout
                    }
                    self.previousScannedCode = newScannedCode
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
                    NewWorkoutFormView(isPresenting: .constant(false), qrCode: previousScannedCode, onComplete: { newWorkout in
                        selectedWorkout = newWorkout
                        activeSheet = nil
                    }, category: $selectedCategory)
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
        let workoutManager = PreviewManager.mockWorkoutManager()
        let categoryManager = CategoryManager()

        return HomeView()
            .environmentObject(workoutManager)
            .environmentObject(categoryManager)
    }
}
