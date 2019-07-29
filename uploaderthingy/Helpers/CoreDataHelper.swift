//
//  CoreDataHelper.swift
//  uploaderthingy
//
//  Created by meme on 7/28/19.
//  Copyright © 2019 generalprogramming. All rights reserved.
//

import UIKit
import CoreData

struct CoreDataHelper {
    static let context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }

        let persistentContainer = appDelegate.persistentContainer
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
