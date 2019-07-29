//
//  SecondViewController.swift
//  uploaderthingy
//
//  Created by meme on 7/27/19.
//  Copyright © 2019 generalprogramming. All rights reserved.
//

import UIKit

class UploadController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var uploadButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    let imagePicker = UIImagePickerController()
    private var data: [UploaderImageQueued] = []
    private var uploader: UploadHelper = UploadHelper()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        imagePicker.delegate = self
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count;
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        tableView.beginUpdates()

        if editingStyle == .delete {
            self.data.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! UploadTableViewCell
        
        cell.fileNameLabel?.text = self.data[indexPath.row].filename
        cell.fileSizeLabel?.text = String(format: "%d bytes", self.data[indexPath.row].size)
        cell.fileImageView?.image = self.data[indexPath.row].image
        
        return cell
    }

    @IBAction func addButtonAction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Camera Roll", style: .default, handler: { _ in
            self.openGallery(sender: sender)
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        switch UIDevice.current.userInterfaceIdiom {
            case .pad:
              alert.popoverPresentationController?.barButtonItem = sender
            default:
                break
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func uploadButtonAction(_ sender: UIBarButtonItem) {
        if (self.data.count == 0) {
            let alert = UIAlertController(title: "Oops!", message: "There no files to upload!", preferredStyle: .alert)
        
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        
            present(alert, animated: true, completion: nil)
            return
        }
        
        self.startUploads()
    }
    
    func startUploads() {
        if (self.data.count == 0) {
//            navigationBar.backBarButtonItem?.isEnabled = true
//            addButton.isEnabled = true
//            uploadButton.isEnabled = true
            return
        }
//
//        navigationBar.backBarButtonItem?.isEnabled = false
//        addButton.isEnabled = false
//        uploadButton.isEnabled = false
        
        let imageToUpload = self.data.removeFirst()
        self.uploader.elixireUpload(toUpload: imageToUpload) {uploaderResponse in
            if ((uploaderResponse?.url) != nil) {
                CoreDataHelper.newUpload(url: uploaderResponse!.url, image: imageToUpload.image)
            }
            print(uploaderResponse.debugDescription)
            DispatchQueue.main.async { [weak self] in
                self?.imageUploaded()
            }
            self.startUploads()
        }
    }
    
    func imageUploaded() {
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        self.tableView.endUpdates()
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "Camera hardware not detected.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    
    func openGallery(sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.modalPresentationStyle = .popover
            imagePicker.popoverPresentationController?.barButtonItem = sender

            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let imgData = NSData(data: pickedImage.jpegData(compressionQuality: 0.75)!)
            let imageSize: Int = imgData.count

            self.data.append(UploaderImageQueued(filename: "upload.png", size: imageSize, image: pickedImage))
            tableView.reloadData()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

