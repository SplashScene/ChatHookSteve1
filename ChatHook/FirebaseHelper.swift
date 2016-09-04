//
//  FirebaseHelper.swift
//  ChatHook
//
//  Created by Kevin Farm on 9/4/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class FirebaseHelper {
    
    func uploadToFirebaseStorageUsingSelectedMedia(image: UIImage?, video: NSURL?, senderId: String) -> [String] {
        let imageName = NSUUID().UUIDString
        var mediaURL: String?
        var contentType: String?
        
        if let picture = image{
            let ref = FIRStorage.storage().reference().child("message_images").child(senderId).child("photos").child(imageName)
            if let uploadData = UIImageJPEGRepresentation(picture, 0.2){
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpg"
                ref.putData(uploadData, metadata: metadata, completion: { (metadata, error) in
                    if error != nil{
                        print(error.debugDescription)
                        return
                    }
                    
                    if let imageUrl = metadata?.downloadURL()?.absoluteString{
                        mediaURL = imageUrl
                        contentType = metadata?.contentType
                       // self.sendMessageWithImageUrl(metadata!.contentType!, fileURL:imageUrl)
                    }
                    
                })
                return [contentType!, mediaURL!]

            }
        } else if let movie = video {
            let ref = FIRStorage.storage().reference().child("message_images").child(senderId).child("videos").child(imageName)
            if let uploadData = NSData(contentsOfURL: movie){
                let metadata = FIRStorageMetadata()
                metadata.contentType = "video/mp4"
                ref.putData(uploadData, metadata: metadata, completion: { (metadata, error) in
                    if error != nil{
                        print(error.debugDescription)
                        return
                    }
                    
                    if let imageUrl = metadata?.downloadURL()?.absoluteString{
                        mediaURL = imageUrl
                        contentType = metadata?.contentType
                        
                        //self.sendMessageWithImageUrl(metadata!.contentType!, fileURL:imageUrl)
                    }
                })
            }
            return [contentType!, mediaURL!]
        }
        return [contentType!, "www.cubs.com"]
    }

}
