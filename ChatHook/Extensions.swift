//
//  Extensions.swift
//  GameOfChats
//
//  Created by Kevin Farm on 8/17/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import FirebaseStorage
import AVFoundation

let imageCache = NSCache()

extension UIImageView{
    func loadImageUsingCacheWithUrlString(urlString: String){
        
        self.image = nil
        //check cache for image first
        
        if let cachedImage = imageCache.objectForKey(urlString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        let url = NSURL(string: urlString)
        NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error?.description)
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                if let downloadedImage = UIImage(data: data!){
                    imageCache.setObject(downloadedImage, forKey: urlString)
                    self.image = downloadedImage
                }
            })
            
        }).resume()
    }
}

extension PostsVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            postedImage = selectedImage
            imageSelectorView.image = postedImage
        }
        
        if let video = info["UIImagePickerControllerMediaURL"] as? NSURL{
            postedVideo = video
            imageSelectorView.image = UIImage(named: "movieIcon")
        }
        self.postButton.userInteractionEnabled = true
        self.postButton.alpha = 1.0
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}//end extension
