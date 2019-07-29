//
//  UploadObjects.swift
//  uploaderthingy
//
//  Created by meme on 7/28/19.
//  Copyright © 2019 generalprogramming. All rights reserved.
//

import UIKit

class UploaderImage {
    var filename: String
    var size: Int
    
    init(filename: String, size: Int) {
        self.filename = filename
        self.size = size
    }
}

class UploaderImageQueued: UploaderImage {
    var image: UIImage
    
    init(filename: String, size: Int, image: UIImage) {
        self.image = image
        super.init(filename: filename, size: size)
    }
}

class UploaderResponse: Decodable {
    var url: String
}
