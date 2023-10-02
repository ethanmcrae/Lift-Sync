//
//  NewWorkoutFormView.swift
//  Lift Sync
//
//  Created by Ethan McRae on 8/4/23.
//

import SwiftUI

struct NewWorkoutFormView: View {
    @EnvironmentObject var categoryManager: CategoryManager
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var isPresenting: Bool
    let qrCode: String?
    var onComplete: ((Workout?) -> Void)
    @Binding var category: String
    @State var newCategoryName = ""
    
    @State var newWorkoutName = ""
    @State var barWeight: Int16 = 0
    let values: [Int16] = stride(from: 0, through: 300, by: 5).map { $0 }
    
    var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        Form {
            // Non-Optional Info
            Section(header: Text("New Exercise")) {
                TextField("Exercise Name", text: $newWorkoutName)
                    .autocapitalization(.words)
                    .font(isiPad ? .title : .body)
                    .padding(.vertical, isiPad ? 12 : 0)
                    .padding(.horizontal, isiPad ? 4 : 0)
                
                Picker("Category", selection: $category) {
                    // Display "Create New" as the FIRST option for QR Scanning workflow
                    if qrCode != nil {
                        Text("Create New")
                            .fontWeight(.semibold)
                            .tag("Create New") // An obscure tag to signify it is the "Create New" option
                    }
                    
                    // Display all custom categories
                    ForEach(categoryManager.categories, id: \.self) { categoryName in
                        Text(categoryName)
//                            .tag(categoryName)
                    }
                    
                    // Display "Create New" as the LAST option for the NON-QR Scanning workflow
                    if qrCode == nil {
                        Text("Create New")
                            .fontWeight(.semibold)
                            .tag("Create New") // An obscure tag to signify it is the "Create New" option
                    }
                }
                .font(isiPad ? .title3 : .body)
                .padding(.vertical, isiPad ? 8 : 0)
                .padding(.horizontal, isiPad ? 4 : 0)
                
                if category.isEmpty || category == "Create New" {
                    TextField("New Category Name", text: $newCategoryName)
                        .font(isiPad ? .title3 : .body)
                }
            }
            .font(isiPad ? .headline : .footnote)
            
            // Optional Info
            Section(header: Text("Optional")) {
                Picker("Bar Weight / Resistance", selection: $barWeight) {
                    ForEach(values, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.automatic)
                .font(isiPad ? .title3 : .body)
                .padding(.vertical, isiPad ? 8 : 0)
                .padding(.horizontal, isiPad ? 4 : 0)
            }
            .font(isiPad ? .subheadline : .footnote)
            
            // Submit
            Section {
                // Cancel
                Button(action: {
                    isPresenting = false
                    onComplete(nil)
                }) {
                    Text("Cancel")
                }
                .foregroundStyle(Color.backgroundInverted.opacity(0.8))
                .font(isiPad ? .title2 : .body)
                .padding(.vertical, isiPad ? 8 : 0)
                .padding(.horizontal, isiPad ? 4 : 0)
                
                // Submit (and create new category)
                if category.isEmpty || category == "Create New" {
                    Button(action: {
                        let trimmedName = newWorkoutName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmedName.isEmpty {
                            let trimmedCategory = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmedCategory.isEmpty {
                                // Create Category
                                categoryManager.create(newCategoryName)
                                
                                // Create workout
                                let newWorkout = workoutManager.createWorkout(name: trimmedName, categoryName: newCategoryName, color: nil, qrCode: qrCode, categoryManager: categoryManager, barWeight: barWeight)
                                newWorkoutName = ""
                                isPresenting = false
                                onComplete(newWorkout)
                            }
                        }
                    }) {
                        Text("Create Exercise & Category")
                    }
                    .font(isiPad ? .title2 : .body)
                    .padding(.vertical, isiPad ? 8 : 0)
                    .padding(.horizontal, isiPad ? 4 : 0)
                    .disabled(newWorkoutName.isEmpty || ((category.isEmpty || category == "Create New") && newCategoryName.isEmpty))
                }
                
                // Submit (normal)
                else {
                    Button(action: {
                        let trimmedName = newWorkoutName.trimmingCharacters(in: .whitespacesAndNewlines)
                        let absoluteCategory: String? = category.isEmpty ? nil : category
                        if !trimmedName.isEmpty {
                            let newWorkout = workoutManager.createWorkout(name: trimmedName, categoryName: absoluteCategory, color: nil, qrCode: qrCode, categoryManager: categoryManager, barWeight: barWeight)
                            newWorkoutName = ""
                            isPresenting = false
                            onComplete(newWorkout)
                        }
                    }) {
                        Text("Create Exercise")
                    }
                    .font(isiPad ? .title2 : .body)
                    .padding(.vertical, isiPad ? 8 : 0)
                    .padding(.horizontal, isiPad ? 4 : 0)
                    .disabled(newWorkoutName.isEmpty)
                }
            }
        }
    }
}

#Preview("Normal") {
    let workoutManager = PreviewManager.mockWorkoutManager()
    let categoryManager = PreviewManager.mockCategoryManager()
    @State var isPresenting = true
    @State var category = "Legs"
    
    return NewWorkoutFormView(isPresenting: $isPresenting, qrCode: nil, onComplete: {_ in }, category: $category)
        .environmentObject(workoutManager)
        .environmentObject(categoryManager)
}

#Preview("QR Scanned") {
    let workoutManager = PreviewManager.mockWorkoutManager()
    let categoryManager = PreviewManager.mockCategoryManager(empty: true)
    @State var isPresenting = true
    @State var category = ""
    
    return NewWorkoutFormView(isPresenting: $isPresenting, qrCode: "ExampleQRCodeUrl", onComplete: {_ in }, category: $category)
        .environmentObject(workoutManager)
        .environmentObject(categoryManager)
}
