//
//  HomeView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/3/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var categoryManager: CategoryManager
    @State private var activeSheet: ActiveSheet?
    @State private var scannedCode: String?
    @State private var selectedWorkout: Workout?
    @State private var selectedCategory = ""
    @State private var previousScannedCode = ""
    @State private var categoryName = ""
    
    // Tutorial State
    let tutorial = TutorialManager.Tutorial.home
    @State private var tutorialStep: Int = TutorialManager.getStep(.home)
    
    private func onDisappear() -> Void {
        self.selectedWorkout = nil
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                NavigationView {
                    VStack {
                        QRScannerButton(isPresentingScanner: Binding<Bool>(
                            get: { self.activeSheet == .scanner },
                            set: { if $0 { self.activeSheet = tutorialStep > 2 ? .scanner : nil } else { self.activeSheet = nil } }
                        ))
                        .popover(isPresented: TutorialManager.isShowingPopover(.home, currentStep: $tutorialStep, expected: 2)) {
                            TutorialHomePopup(text: "Optional: Scan QR Codes by each machine to access your workout.", step: $tutorialStep, tutorial: tutorial)
                        }
                        .frame(height: geometry.size.height * 0.3)
                        ZStack {
                            Color("BackgroundColor")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .edgesIgnoringSafeArea(.all)
                            VStack {
                                // Add "Create First" category button
                                if categoryManager.categories.isEmpty {
                                    CreateFirstCategoryForm(categoryName: $categoryName, tutorialStep: $tutorialStep, tutorial: tutorial)
                                } else {
                                    WorkoutCategoryView(selectedCategory: $selectedCategory, homeTutorialStep: $tutorialStep)
                                    
                                    WorkoutGridView(selectedCategory: $selectedCategory, onDisappear: self.onDisappear, homeTutorialStep: $tutorialStep)
                                    
                                    Spacer()
                                }
                            }
                            .frame(height: geometry.size.height * 0.7)
                        }
                        if selectedWorkout != nil {
                            NavigationLink(destination: SelectedWorkoutView(workout: Binding<Workout>(get: { selectedWorkout! }, set: { newValue in selectedWorkout = newValue }), onDisappear: self.onDisappear), isActive: Binding<Bool>(get: { selectedWorkout != nil }, set: { _ in })) {
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
            
            // Tutorial View 1
            if tutorialStep == 1 {
                TutorialHomeView_1(tutorialStep: $tutorialStep, tutorial: tutorial)
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
        let categoryManager = PreviewManager.mockCategoryManager()

        return HomeView()
            .environmentObject(workoutManager)
            .environmentObject(categoryManager)
    }
}
