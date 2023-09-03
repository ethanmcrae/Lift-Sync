//
//  CategoryManager.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/3/23.
//

import Foundation

class CategoryManager: ObservableObject {
    @Published var categories: [String] {
        didSet {
            // When categories change, save them to iCloud
            NSUbiquitousKeyValueStore.default.set(categories, forKey: "categories")
            // Also save them to UserDefaults to be accessible across App Groups
            UserDefaults(suiteName: "com.ethanmcrae.Lift-Scan")?.set(categories, forKey: "categories")
        }
    }

    init() {
        // Try to load categories from iCloud, or use a default set
        categories = NSUbiquitousKeyValueStore.default.array(forKey: "categories") as? [String] ?? []
    }
    
    func removeCategory(_ categoryName: String) {
        categories = categories.filter({ $0 != categoryName })
    }
}
