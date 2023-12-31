//
//  HomeView.swift
//  Lift Sync
//
//  Created by Ethan McRae on 8/3/23.
//

import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var categoryManager: CategoryManager
    @State private var activeSheet: ActiveSheet?
    @State private var scannedCode: String?
    @State private var selectedWorkout: Workout?
    @State private var selectedCategory = ""
    @State private var previousScannedCode = ""
    @State private var categoryName = ""
    
    // Categories
    @State private var isAddNewCategorySelected = false
    
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
                            TutorialHomePopup(text: "If your gym's machines have QR codes on them, use this to quickly pull up your workout logs for that exercise.", step: $tutorialStep, tutorial: tutorial)
                        }
                        .frame(height: geometry.size.height * 0.3)
                        
                        ZStack {
                            Color("BackgroundColor")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .edgesIgnoringSafeArea(.all)
                            VStack {
                                // Add "Create First" category button
                                if categoryManager.categories.isEmpty && tutorialStep != 1 {
                                    CreateFirstCategoryForm(categoryName: $categoryName, tutorialStep: $tutorialStep, tutorial: tutorial)
                                } else {
                                    WorkoutCategoryView(selectedCategory: $selectedCategory, homeTutorialStep: $tutorialStep, isAddNewSelected: $isAddNewCategorySelected)
                                    
                                    WorkoutGridView(selectedCategory: $selectedCategory, onDisappear: self.onDisappear, homeTutorialStep: $tutorialStep, isAddNewCategorySelected: $isAddNewCategorySelected)
                                    
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
                    .background(Color.accentColor600.gradient)
                    .onChange(of: scannedCode) { _ in
                        if let newScannedCode = scannedCode {
                            let foundWorkout = self.workoutManager.getWorkout(byCode: newScannedCode)
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
                .navigationViewStyle(StackNavigationViewStyle())
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

#Preview {
    let workoutManager = PreviewManager.mockWorkoutManager()
    let categoryManager = PreviewManager.mockCategoryManager()
    
    // Skip tutorial
    TutorialManager.updateStep(.home, step: -1)

    return HomeView()
        .environmentObject(workoutManager)
        .environmentObject(categoryManager)
}

#Preview("Tutorial") {
    let workoutManager = PreviewManager.mockWorkoutManager()
    let categoryManager = PreviewManager.mockCategoryManager(empty: true)
    
    // Reset tutorial
    TutorialManager.updateStep(.home, step: 1)

    return HomeView()
        .environmentObject(workoutManager)
        .environmentObject(categoryManager)
}
