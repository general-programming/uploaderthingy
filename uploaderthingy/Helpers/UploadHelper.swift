//
//  UploadHelper.swift
//  uploaderthingy
//
//  Created by meme on 7/28/19.
//  Copyright © 2019 generalprogramming. All rights reserved.
//

import UIKit

class UploadHelper: NSObject {
    var queue: [UploaderImageQueued] = []
    
    func elixireUpload(toUpload: UploaderImageQueued, callback: @escaping (UploaderResponse?) -> Void) {
        self.postUpload(toUpload: toUpload, url: ELIXIRE_UPLOAD_API, headers: [
            "Authorization": "insert your own token"
        ], formName: "f", callback: callback)
    }
    
    func createMultipath(formName: String, imageData: Data, boundary: String) -> Data {
        var data = Data()
        // Code snippet from https://fluffy.es/upload-image-to-server/#swiftcode

        // Add the image data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"\(formName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(imageData)

        // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
        // According to the HTTP 1.1 specification https://tools.ietf.org/html/rfc7230
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        return data
    }
    
    func postUpload(toUpload: UploaderImageQueued, url: String, headers: Dictionary<String, String>, formName: String, callback: @escaping (UploaderResponse?) -> Void) {
        // Build URL and request data.
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        let boundary = UUID().uuidString + "_IOSUPLOADER"
        let imageData = toUpload.image.jpegData(compressionQuality: 0.80)!
        guard let uploadData = try? self.createMultipath(formName: formName, imageData: imageData, boundary: boundary) else {
            return callback(nil)
        }
        
        // Set method and headers
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let task = URLSession.shared.uploadTask(with: request, from: uploadData) {
            data, response, error in if let error = error {
                print ("error: \(error)")
                return callback(nil)
            }

            // XXX: what's a valid status code
            if let jsonString = String(data: data!, encoding: .utf8) {
                print(jsonString)
             }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                print("server bad status code")
                return callback(nil)
            }

            // XXX: wtf lol
            if let mimeType = response.mimeType, mimeType == "application/json", let data = data {
                do {
                    let res = try JSONDecoder().decode(UploaderResponse.self, from: data)
                    return callback(res)
                } catch {
                    print ("parse error: \(error)")
                    return callback(nil)
                }
            }
        }
        
        task.resume()
    }
}
