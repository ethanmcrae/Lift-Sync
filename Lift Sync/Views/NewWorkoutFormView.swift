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
    
    @State var newWorkoutName = ""
    @State var barWeight: Int16 = 0
    let values: [Int16] = stride(from: 0, through: 300, by: 5).map { $0 }
    
    var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        Form {
            // Non-Optional Info
            Section(header: Text("New Workout")) {
                TextField("Workout Name", text: $newWorkoutName)
                    .autocapitalization(.words)
                    .font(isiPad ? .title : .body)
                    .padding(.vertical, isiPad ? 12 : 0)
                    .padding(.horizontal, isiPad ? 4 : 0)
                
                Picker("Category", selection: $category) {
                    ForEach(categoryManager.categories, id: \.self) { categoryName in
                        Text(categoryName)
                    }
                }
                .font(isiPad ? .title3 : .body)
                .padding(.vertical, isiPad ? 8 : 0)
                .padding(.horizontal, isiPad ? 4 : 0)
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
                
                // Submit
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
                    Text("Create Workout")
                }
                .font(isiPad ? .title2 : .body)
                .padding(.vertical, isiPad ? 8 : 0)
                .padding(.horizontal, isiPad ? 4 : 0)
            }
        }
    }
}

#Preview {
    let workoutManager = PreviewManager.mockWorkoutManager()
    let categoryManager = PreviewManager.mockCategoryManager()
    @State var isPresenting = true
    @State var category = "Legs"
    
    return NewWorkoutFormView(isPresenting: $isPresenting, qrCode: "ExampleQRCodeUrl", onComplete: {_ in }, category: $category)
        .environmentObject(workoutManager)
        .environmentObject(categoryManager)
}
