//
//  CreateFirstCategoryForm.swift
//  Lift Sync
//
//  Created by Ethan McRae on 9/17/23.
//

import SwiftUI
import CoreData

struct CreateFirstCategoryForm: View {
    @EnvironmentObject var categoryManager: CategoryManager
    @Binding var categoryName: String
    @Binding var tutorialStep: Int
    let tutorial: TutorialManager.Tutorial
    
    var body: some View {
        Form {
            Section {
                TextField("Category Name...", text: $categoryName)
                    .autocapitalization(.words)
                    .font(.title3)
                    .padding(.horizontal, 3)
                    .padding(.vertical, 10)
                    .popover(isPresented: TutorialManager.isShowingPopover(.home, currentStep: $tutorialStep, expected: 3)) {
                    TutorialHomePopup(text: "Name your first workout category, such as: Legs, Core, Back / Biceps, etc...", step: $tutorialStep, tutorial: TutorialManager.Tutorial.home)
                }
                Button("Create") {
                    guard !categoryName.isEmpty else { return }
                    categoryManager.create(categoryName)
                    categoryName = ""
                }
                .font(.title3)
            } header: {
                VStack {
                    Text("Workout Category")
                        .font(.title2)
                        .padding(.vertical, 30)
                }
            }
        }
    }
}

#Preview {
    var categoryManager = CategoryManager(container: NSPersistentCloudKitContainer(name: "Lift_Scan"))
    @State var categoryName = ""
    @State var tutorialStep = 0
    let tutorial = TutorialManager.Tutorial.home
    
    return CreateFirstCategoryForm(categoryName: $categoryName, tutorialStep: $tutorialStep, tutorial: tutorial)
        .environmentObject(categoryManager)
}

#Preview("Tutorial") {
    var categoryManager = CategoryManager(container: NSPersistentCloudKitContainer(name: "Lift_Scan"))
    @State var categoryName = ""
    @State var tutorialStep = 3
    let tutorial = TutorialManager.Tutorial.home
    
    return CreateFirstCategoryForm(categoryName: $categoryName, tutorialStep: $tutorialStep, tutorial: tutorial)
        .environmentObject(categoryManager)
}
