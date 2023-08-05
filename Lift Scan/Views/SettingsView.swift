//
//  SettingsView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/3/23.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var categoryManager: CategoryManager
    @State private var name = ""
    @State private var category = ""
    @State private var color = Color(.yellow)
    @State private var newCategory = ""
    @State private var deleteCategoryIndex: Int? = nil
    @State private var showingDeleteCategoryAlert = false
    @State private var showingRemoveCustomWorkoutsAlert = false
    @State private var showingRemoveAllWorkoutsAlert = false
    
    private func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    var body: some View {
        Form {
            if !categoryManager.categories.isEmpty {
                Section(header: Text("New Custom Workouts")) {
                    TextField("Name", text: $name)
                    Picker("Workout Category", selection: $category) {
                        ForEach(categoryManager.categories, id: \.self) { categoryName in
                            Text(categoryName)
                        }
                    }
                    ColorPicker(selection: $color, label: {
                        Text("Choose color")
                    })
                    Button(action: {
                        print("Submitting: New Workout Form")
                        print("Color \($color)")
                        print("Category \($category)")
                        print("Name \($name)")
                        guard !category.isEmpty else { return }
                        guard !name.isEmpty else { return }
                        
                        print("\n\n")
                        print("Submitted ✅")
                        
                        workoutManager.createWorkout(name: name, category: category, color: color.hexString, categoryManager: categoryManager)
                        
                        // Reset form element(s)
                        name = ""
                        self.endEditing()
                    }) {
                        Text("Add Workout")
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {
                        if let firstCategory = categoryManager.categories.first {
                            category = firstCategory
                        }
                    }
                }
            }
            
            Section(header: Text("Manage Categories")) {
                List {
                    ForEach(Array(zip(categoryManager.categories.indices, categoryManager.categories)), id: \.1) { index, category in
                        Text(category)
                    }
                    .onDelete { indexSet in
                        guard let index = indexSet.first else { return }
                        deleteCategoryIndex = index
                        showingDeleteCategoryAlert = true
                    }
                    .alert(isPresented: $showingDeleteCategoryAlert) {
                        Alert(
                            title: Text("Remove category?"),
                            message: Text("Are you sure you want to remove this category? This cannot be undone."),
                            primaryButton: .destructive(Text("Remove")) {
                                if let index = deleteCategoryIndex {
                                    categoryManager.categories.remove(at: index)
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                
                HStack {
                    TextField("Legs, Chest, Back / Bicepts", text: $newCategory)
                    Button(action: {
                        guard newCategory != "" else { return }
                        categoryManager.categories.append(newCategory)
                        // Reset form
                        newCategory = ""
                        self.endEditing()
                    }) {
                        Text("Add Category")
                    }
                }
            }
            
            Section(header: Text("Manage Workouts")) {
                Button("Remove all custom workouts") {
                    showingRemoveCustomWorkoutsAlert = true
                }
                .foregroundColor(.red)
                .alert(isPresented: $showingRemoveCustomWorkoutsAlert) {
                    Alert(
                        title: Text("Remove all custom workouts?"),
                        message: Text("Are you sure you want to remove all custom workouts? This cannot be undone."),
                        primaryButton: .destructive(Text("Remove")) {
                            workoutManager.removeCustomWorkouts()
                        },
                        secondaryButton: .cancel()
                    )
                }
                
                Button("Remove all workouts") {
                    showingRemoveAllWorkoutsAlert = true
                }
                .foregroundColor(.red)
                .alert(isPresented: $showingRemoveAllWorkoutsAlert) {
                    Alert(
                        title: Text("Remove all workouts?"),
                        message: Text("Are you sure you want to remove all workouts? This cannot be undone."),
                        primaryButton: .destructive(Text("Remove")) {
                            workoutManager.removeAllWorkouts()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let categoryManager = CategoryManager()
        let container = previewContainer()
        let context = container.viewContext
        
        SettingsView()
            .environmentObject(WorkoutManager(container: container))
            .environmentObject(categoryManager)
    }
}
