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
    @State private var color = Color("AccentColor-400")
    @State private var newCategory = ""
    @State private var deleteCategoryIndex: Int? = nil
    @State private var showingDeleteCategoryAlert = false
    @State private var showingRemoveCustomWorkoutsAlert = false
    @State private var showingRemoveAllWorkoutsAlert = false
    
    private func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func areThereCategories() -> Bool {
        return !categoryManager.categories.isEmpty
    }

    var body: some View {
        Form {
            if areThereCategories() {
                // 🟩 Create Workout
                Section(header: Text("Add New Workout").font(.headline).padding(.bottom, 10)) {
                    
                    TextField("Name", text: $name)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categoryManager.categories, id: \.self) { categoryName in
                            Text(categoryName)
                        }
                    }
                    
                    ColorPicker(selection: $color, label: {
                        Text("Color")
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
                        
                        workoutManager.createWorkout(name: name, categoryName: category, color: color.toHex(), categoryManager: categoryManager)
                        
                        // Reset form element(s)
                        name = ""
                        self.endEditing()
                    }) {
                        Text("Create Workout")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .foregroundColor(Color("AccentColor"))
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {
                        if let firstCategory = categoryManager.categories.first {
                            category = firstCategory
                        }
                    }
                }
                
                Section {
                   
                }
                .frame(maxWidth: .infinity)
            }
            
            // 🟩 Create Category
            Section {
                Section {
                    TextField("Category name...", text: $newCategory)
                }
                Section {
                    Button(action: {
                        // Update state
                        categoryManager.create(newCategory)
                        // Reset form
                        newCategory = ""
                        self.endEditing()
                    }) {
                        Text("Create Category")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .foregroundColor(Color("AccentColor"))
                    }
                }
            } header: {
                VStack(alignment: .leading) {
                    Divider()
                        .padding(.vertical, 10)
                    Text("Add New Category")
                        .font(.headline)
                        .padding(.bottom, 10)
                }
            }
            
            // 🟨 Modify Categories
            if self.areThereCategories() {
                Section {
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
                                        categoryManager.delete(categoryManager.categories[index])
                                    }
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                } header: {
                    VStack(alignment: .leading) {
                        Divider()
                            .padding(.vertical, 10)
                        Text("Existing Categories")
                            .font(.headline)
                            .padding(.bottom, 10)
                    }
                }
            }
            
            Section {
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
            } header: {
                VStack(alignment: .leading) {
                    Divider()
                        .padding(.vertical, 10)
                    Text("Delete Workouts")
                        .font(.headline)
                        .padding(.bottom, 10)
                }
            }
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutManager = PreviewManager.mockWorkoutManager()
        let categoryManager = PreviewManager.mockCategoryManager()
        
        SettingsView()
            .environmentObject(workoutManager)
            .environmentObject(categoryManager)
    }
}
