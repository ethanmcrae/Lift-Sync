//
//  CategoryManager.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/3/23.
//

import Foundation
import CoreData
import SwiftUI

class CategoryManager: ObservableObject {
    // Category entities
    @Published var categoryEntities: [Category] = []
    
    // names of the Category entities for UI
    @Published var categories: [String] = []

    let container: NSPersistentCloudKitContainer
    let viewContext: NSManagedObjectContext

    init(container: NSPersistentCloudKitContainer) {
        self.container = container
        self.viewContext = container.viewContext
        fetchCategories()
        self.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    private func fetchCategories() {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()

        do {
            let fetchedCategories = try viewContext.fetch(fetchRequest)
            self.categoryEntities = fetchedCategories
            self.categories = fetchedCategories.map { $0.name! }

        } catch {
            print("Failed to fetch categories: \(error)")
        }
    }

    func categoryExists(_ name: String) -> Bool {
        let trimmedString = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return categories.contains { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == trimmedString }
    }

    func create(_ name: String) {
        guard !name.isEmpty else {
            print("Empty category name input")
            return // Exit early if the category name is empty
        }
        
        // Ensure the name is properly trimmed and case is ignored
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // Check if the category name already exists
        if categoryExists(trimmedName) {
            print("Category \(name) already exists!")
            return // Exit early if the category already exists
        }

        // Create and save the new category
        let newCategory: Category = Category(context: viewContext)
        newCategory.name = name.trimmingCharacters(in: .whitespacesAndNewlines)

        categoryEntities.append(newCategory)
        categories.append(newCategory.name!)

        updateCloud(errorMessage: "Error saving category")
    }
    
    func rename(from oldName: String, to newName: String) {
        guard !newName.isEmpty else {
            print("Empty category name input")
            return // Exit early if the category name is empty
        }
        
        // Ensure the names are properly trimmed and case is ignored
        let trimmedOldName = oldName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedNewName = newName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // Check if the category with the old name exists
        guard categoryExists(trimmedOldName) else {
            print("Category \(oldName) doesn't exist!")
            return // Exit early if the category doesn't exist
        }

        // Check if the new name already exists
        if categoryExists(trimmedNewName) {
            print("Category with name \(newName) already exists!")
            return // Exit early if a category with the new name already exists
        }

        // Rename the category in the entities
        if let categoryToRename = categoryEntities.first(where: { $0.name?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == trimmedOldName }) {
            categoryToRename.name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // Update local arrays
        if let index = categories.firstIndex(of: oldName) {
            categories[index] = newName
        }

        // Update the cloud
        updateCloud(errorMessage: "Error renaming category")
    }
    
    func delete(_ name: String) {
        // Ensure the name is properly trimmed and case is ignored
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // Check if the category with the given name exists
        guard categoryExists(trimmedName) else {
            print("Category \(name) doesn't exist!")
            return // Exit early if the category doesn't exist
        }

        // Delete the category from the entities
        if let categoryToDelete = categoryEntities.first(where: { $0.name?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == trimmedName }) {
            categoryEntities.removeAll { $0 == categoryToDelete }
            viewContext.delete(categoryToDelete)
        }

        // Update local arrays
        categories.removeAll { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == trimmedName }

        // Update the cloud
        updateCloud(errorMessage: "Error deleting category")
    }


    func updateCloud(errorMessage: String) {
        do {
            try viewContext.save()
            fetchCategories()
        } catch {
            print("\(errorMessage): \(error)")
        }
    }
}

