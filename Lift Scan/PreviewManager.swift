//
//  PreviewManager.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/4/23.
//

import Foundation
import CoreData

func previewContainer() -> NSPersistentCloudKitContainer {
    let container = NSPersistentCloudKitContainer(name: "Lift_Scan")
    let description = NSPersistentStoreDescription()
    description.url = URL(fileURLWithPath: "/dev/null")
    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { (storeDescription, error) in
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    return container
}
