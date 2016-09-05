//
//  ChatViewController+Image.swift
//  ChatHook
//
//  Created by Kevin Farm on 9/4/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import FirebaseStorage
import AVFoundation

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            
            uploadToFirebaseStorageUsingSelectedMedia(selectedImage, video: nil)
        }
        
        if let video = info["UIImagePickerControllerMediaURL"] as? NSURL{

            uploadToFirebaseStorageUsingSelectedMedia(nil, video: video)
        }
        
        self.finishSendingMessage()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func uploadToFirebaseStorageUsingSelectedMedia(image: UIImage?, video: NSURL?){
        let imageName = NSUUID().UUIDString
        
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
                        self.sendMessageWithImageUrl(metadata!.contentType!, fileURL:imageUrl)
                    }
                })
            }
            
        } else if let movie = video {
            let ref = FIRStorage.storage().reference().child("message_images").child(senderId).child("videos").child(imageName)
            if let uploadData = NSData(contentsOfURL: movie){
                let metadata = FIRStorageMetadata()
                    metadata.contentType = "video/mp4"
                let uploadTask = ref.putData(uploadData, metadata: metadata, completion: { (metadata, error) in
                    if error != nil{
                        print(error.debugDescription)
                        return
                    }
                    
                    if let imageUrl = metadata?.downloadURL()?.absoluteString{
                        
                        if let thumbnailImage = self.thumbnailImageForVideoUrl(movie){
                            
                        }
                        
                        self.sendMessageWithImageUrl(metadata!.contentType!, fileURL:imageUrl)
                    }
                })
                
                uploadTask.observeStatus(.Progress) { (snapshot) in
                    if let completedUnitCount = snapshot.progress?.completedUnitCount{
                        self.setupNavBarWithUserOrProgress(String(completedUnitCount))
                    }
                }
                
                uploadTask.observeStatus(.Success) { (snapshot) in
                    self.setupNavBarWithUserOrProgress(nil)
                }
            }
        }
    }
    
    private func sendMessageWithImageUrl(metadata: String, fileURL: String){
        let toId = user?.postKey
        let itemRef = DataService.ds.REF_MESSAGES.childByAutoId()
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        let messageItem: Dictionary<String,AnyObject>
        
        if metadata == "video/mp4"{
            messageItem = ["fromId": senderId,
                           "imageUrl": fileURL,
                           "timestamp" : timestamp,
                           "toId": toId!,
                           "mediaType": "VIDEO"]
        }else{
            messageItem = ["fromId": senderId,
                           "imageUrl": fileURL,
                           "timestamp" : timestamp,
                           "toId": toId!,
                           "mediaType": "PHOTO"]
        }
        
        
        itemRef.updateChildValues(messageItem) { (error, ref) in
            if error != nil {
                print(error?.description)
                return
            }
            
            let userMessagesRef = DataService.ds.REF_BASE.child("user_messages").child(self.senderId).child(toId!)
            let messageID = itemRef.key
            userMessagesRef.updateChildValues([messageID: 1])
            
            let recipientUserMessagesRef = DataService.ds.REF_BASE.child("user_messages").child(toId!).child(self.senderId)
            recipientUserMessagesRef.updateChildValues([messageID: 1])
        }
    }
    
    private func thumbnailImageForVideoUrl(videoUrl: NSURL) -> UIImage?{
        let asset = AVAsset(URL: videoUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do{
           let thumbnailCGImage = try imageGenerator.copyCGImageAtTime(CMTimeMake(1, 60), actualTime: nil)
            return UIImage(CGImage: thumbnailCGImage)
        }catch let err{
            print(err)
        }
        
        return nil
        
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
