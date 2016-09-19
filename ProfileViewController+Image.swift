//
//  ProfileViewController+Image.swift
//  ChatHook
//
//  Created by Kevin Farm on 9/14/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            if photoChoice == "Profile"{
                uploadToFirebaseStorageUpdateProfilePic(selectedImage)
            }else{
                uploadToFirebaseStorageAddToGallery(selectedImage)
            }
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func uploadToFirebaseStorageUpdateProfilePic(selectedImage: UIImage){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        let imageName = NSUUID().UUIDString
        
        let storageRef = FIRStorage.storage().reference().child("profile_images").child(uid).child("profile_pic").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(selectedImage, 0.2){
            let uploadTask = storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error.debugDescription)
                    return
                }
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                    let userRef = DataService.ds.REF_USERS.child(uid).child("ProfileImage")
                    userRef.setValue(profileImageUrl)
                    
                }
            })
            uploadTask.observeStatus(.Progress) { (snapshot) in
                if let completedUnitCount = snapshot.progress?.completedUnitCount{
                    self.navigationItem.title = "\(completedUnitCount)"
                }
            }
            
            uploadTask.observeStatus(.Success) { (snapshot) in
                self.profileImageView.image = selectedImage
                self.navigationItem.title = self.currentUser?.userName
                
            }
        }
        
    }
    
    private func uploadToFirebaseStorageAddToGallery(selectedImage: UIImage){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let imageName = NSUUID().UUIDString
        
        let storageRef = FIRStorage.storage().reference().child("gallery_images").child(uid).child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(selectedImage, 0.2){
            let uploadTask = storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error.debugDescription)
                    return
                }
                if let galleryImageUrl = metadata?.downloadURL()?.absoluteString{
                    let galleryRef = DataService.ds.REF_GALLERYIMAGES.childByAutoId()
                    let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
                    let galleryItem : [String: AnyObject] = ["fromId": uid, "timestamp" : timestamp,"galleryImageUrl": galleryImageUrl]
                    
                    galleryRef.updateChildValues(galleryItem, withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print(error?.description)
                            return
                        }
                        
                        let galleryUserRef = DataService.ds.REF_USERS_GALLERY.child(uid)
                        let galleryID = galleryRef.key
                        galleryUserRef.updateChildValues([galleryID: 1])
                        
                    })
                    
                }
            })
            
            uploadTask.observeStatus(.Progress) { (snapshot) in
                if let completedUnitCount = snapshot.progress?.completedUnitCount{
                    self.navigationItem.title = "\(completedUnitCount)"
                }
            }
            
            uploadTask.observeStatus(.Success) { (snapshot) in
                self.navigationItem.title = self.currentUser?.userName
            }
        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("I hit cancel")
    }
    
    func takePhotoWithCamera(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func pickPhoto(){
        if UIImagePickerController.isSourceTypeAvailable(.Camera){
            showPhotoMenu()
        }else{
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: {
            _ in
            self.takePhotoWithCamera()
        })
        alertController.addAction(takePhotoAction)
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .Default, handler: {
            _ in
            self.choosePhotoFromLibrary()
        })
        alertController.addAction(chooseFromLibraryAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}