//
//  CoreDataHelper.swift
//  uploaderthingy
//
//  Created by meme on 7/28/19.
//  Copyright © 2019 generalprogramming. All rights reserved.
//

import UIKit
import CoreData
import Social

struct CoreDataHelper {
    // MARK: - Core Data stack

    static var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "UploaderModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    static func saveContext () {
        print("Saving CoreData context.")
        let context = CoreDataHelper.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    static let context: NSManagedObjectContext = {
        let persistentContainer = CoreDataHelper.persistentContainer
        let context = persistentContainer.viewContext

        return context
    }()
    
    static func save() {
        do {
            try CoreDataHelper.context.save()
        } catch let error as NSError {
            fatalError("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    static func newUpload(url: String, image: UIImage) {
        let newImage = UploadedFile(context: CoreDataHelper.context)
        let jpegPreview = image.jpegData(compressionQuality: 0.1)

        newImage.url = url
        newImage.size = Int64(image.jpegData(compressionQuality: 0.75)!.count)
        newImage.preview = jpegPreview
        newImage.uploadtime = Date.init()
        
        self.save()
    }
}
