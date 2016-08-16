//
//  RegisterVC.swift
//  PlayLife
//
//  Created by Kevin Farm on 4/25/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class RegisterVC: UIViewController {
    @IBOutlet weak var imgProfilePic: MaterialImageView!
    @IBOutlet weak var imgCameraIcon: UIImageView!
    @IBOutlet weak var txtUserName: MaterialTextField!
    @IBOutlet weak var txtFullName: MaterialTextField!
    @IBOutlet weak var txtEmailAddress: MaterialTextField!
    @IBOutlet weak var txtPassword: MaterialTextField!
    @IBOutlet weak var btnRegister: MaterialButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    // MARK: - Properties
    private var tags: [String]?
    private var _userPicLink: String?
    
    let currentUser = DataService.ds.REF_USER_CURRENT
    
    var emailAddress:String? = ""
    var password:String? = ""
 
    override func viewDidLoad() {
        
        super.viewDidLoad()
        imgCameraIcon.hidden = false
        activityIndicator.hidden = true
        
        if let email = emailAddress, pwd = password{
            txtEmailAddress.text = email
            txtPassword.text = pwd
        }

    }
    
    @IBAction func cameraButtonTapped(sender: UIButton) {
        pickPhoto()
    }

    @IBAction func registerButtonTapped(sender: UIButton) {
        
        guard let userName = txtUserName.text where userName != "",
               let fullName = txtFullName.text where fullName != "",
               let email = txtEmailAddress.text where email != "",
               let pwd = txtPassword.text where pwd != "" else { return }
        
            btnRegister.enabled = true
            imgCameraIcon.hidden = true
            progressView.progress = 0.0
            progressView.hidden = false
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
        
        
        let imageName = NSUUID().UUIDString
        let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).png")
        
        if let uploadData = UIImagePNGRepresentation(self.imgProfilePic.image!){
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error.debugDescription)
                    return
                }
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                    let values = ["UserName": userName,
                                  "email":email,
                                  "ProfileImage": profileImageUrl,
                                  "FullName": fullName]
                    self.postRegisteredUserToFirebase(values, progress: {[unowned self] percent in
                        self.progressView.setProgress(percent, animated: true)
                        })
                }
            })
        }
}

    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func postRegisteredUserToFirebase(values:[String: String], progress: (percent: Float) -> Void){
        currentUser.child("UserName").setValue(values["UserName"])
        currentUser.child("FullName").setValue(values["FullName"])
        currentUser.child("ProfileImage").setValue(values["ProfileImage"])
        self.progressView.hidden = true
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
        self.performSegueWithIdentifier("registered", sender: nil)
    }
    
    func showErrorAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

}


extension RegisterVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            print("Info did not have the required UIImage for the Original Image")
            dismissViewControllerAnimated(true, completion: nil)
            return
        }
//        uploadImage(image)
        imgProfilePic.image = image
        imgCameraIcon.hidden = true
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}//end extension
