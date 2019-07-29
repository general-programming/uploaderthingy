//
//  BaseController.swift
//  uploaderthingy
//
//  Created by meme on 7/28/19.
//  Copyright © 2019 generalprogramming. All rights reserved.
//

import UIKit

class UploadTableViewCell: UITableViewCell {
    @IBOutlet weak var fileImageView: UIImageView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!
    @IBOutlet weak var fileProgressBar: UIProgressView!
}

class BaseController: UINavigationController {
    
}
