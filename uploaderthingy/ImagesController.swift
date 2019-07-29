//
//  ImagesController
//  uploaderthingy
//
//  Created by meme on 7/27/19.
//  Copyright © 2019 generalprogramming. All rights reserved.
//

import UIKit
import CoreData

class ImagesController: UITableViewController {
    var images: [UploadedFile] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(loadImages), for: .valueChanged)
        
        self.loadImages()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! UploadTableViewCell
                
        cell.fileNameLabel?.text = self.images[indexPath.row].uploadtime?.description
        cell.fileSizeLabel?.text = self.images[indexPath.row].url
        cell.fileImageView?.image = UIImage(data: self.images[indexPath.row].preview!)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Row tapped.")
        let image = self.images[indexPath.row]
        
        let alert = UIAlertController(title: "Image " + (image.url ?? "Unknown URL???"), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Copy URL", style: .default, handler: { _ in
            UIPasteboard.general.string = image.url
        }))
        
        alert.addAction(UIAlertAction(title: "Delete Image", style: .destructive, handler: { _ in
            // XXX: Delete image code
        }))
        
        alert.addAction(UIAlertAction.init(title: "Close", style: .cancel, handler: nil))
        
        switch UIDevice.current.userInterfaceIdiom {
            case .pad:
              alert.popoverPresentationController?.sourceView = tableView
            default:
                break
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let image = self.images[indexPath.row]
        let action = UIContextualAction(
            style: .normal,
            title: "Copy URL",
            handler: {(action, view, completion) in
                UIPasteboard.general.string = image.url
                completion(true)
            }
        )
        
        let config = UISwipeActionsConfiguration(actions: [action])
        config.performsFirstActionWithFullSwipe = true

        return config
    }
    
    
    @objc func loadImages() {
        let imageFetch = NSFetchRequest<UploadedFile>(entityName: "UploadedFile")
        let sort = NSSortDescriptor(key: #keyPath(UploadedFile.uploadtime), ascending: false)
        imageFetch.sortDescriptors = [sort]
        
        do {
            let fetchedImages = try CoreDataHelper.context.fetch(imageFetch)
            self.images = fetchedImages
        } catch {
            fatalError("Failed to fetch images: \(error)")
        }
        
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
}

