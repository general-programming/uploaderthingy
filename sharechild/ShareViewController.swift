//
//  ShareViewController.swift
//  sharechild
//
//  Created by meme on 7/29/19.
//  Copyright © 2019 generalprogramming. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import CoreData

class ShareViewController: SLComposeServiceViewController {
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        guard let extensionContext = extensionContext else { return }
        let uploader: UploadHelper = UploadHelper()

        ShareViewController.sharedImageData(extensionContext: extensionContext) { imageData in
            print("imageData acq \(imageData?.count)")
            guard let imageData = imageData else {
                extensionContext.completeRequest(returningItems: [], completionHandler: self.completionHandler)
                return
            }

            let imageToUpload = UploaderImageQueued(
                filename: "sharesheet.jpg",
                size: imageData.count,
                image: UIImage(data: imageData as Data)!
            )

            uploader.elixireUpload(toUpload: imageToUpload) {uploaderResponse in
                if ((uploaderResponse?.url) != nil) {
                    CoreDataHelper.newUpload(url: uploaderResponse!.url, image: imageToUpload.image)
                    UIPasteboard.general.string = uploaderResponse!.url
                }
                print(uploaderResponse.debugDescription)
                // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
                extensionContext.completeRequest(returningItems: [], completionHandler: self.completionHandler)
            }
        }
    }

    private static func sharedImageData(extensionContext: NSExtensionContext, result: @escaping (NSData?)->()) {
        let imageType = kUTTypeImage as String
        print("sharedImageData parse attempt")

        guard let item = extensionContext.inputItems.first as? NSExtensionItem else {
            print("extensionContext.inputItems.first failed to exist")
            result(nil)
            return
        }
        
        print(item.attachments?.first)
        
        let attachment = item.attachments!.first
        // XXX: god this is a hack
        attachment?.loadItem(forTypeIdentifier: imageType, options: nil) { data, error in
            if data is UIImage {
                result((data as! UIImage).pngData() as NSData?)
                return
            } else if (data is URL) {
                result(NSData(contentsOf: data as! URL))
            } else {
                print(data)
                result(data as? NSData)
                return
            }
        }
    }
    
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    func completionHandler(expired: Bool) {
        // Save CoreData context before closing.
        CoreDataHelper.saveContext()
    }
}
