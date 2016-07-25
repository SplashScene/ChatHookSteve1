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
//        btnRegister.enabled = false
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cameraButtonTapped(sender: UIButton) {
        pickPhoto()
    }

    @IBAction func registerButtonTapped(sender: UIButton) {
        if let userName = txtUserName.text where userName != "",
           let fullName = txtFullName.text where fullName != "",
           let email = txtEmailAddress.text where email != "",
           let pwd = txtPassword.text where pwd != "",
           let picLink = _userPicLink where picLink != ""{
            
            btnRegister.enabled = true
            imgCameraIcon.hidden = true
            progressView.progress = 0.0
            progressView.hidden = false
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            
            uploadImaggaImage(self.imgProfilePic.image!,
                              progress: {[unowned self] percent in
                                self.progressView.setProgress(percent, animated: true)
                },
                              completion: {[unowned self] tags in
                                
                                self.progressView.hidden = true
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.hidden = true
                                self.tags = tags
                })
            
            postRegisteredUserToFirebase(picLink)
        }
    }

    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func postRegisteredUserToFirebase(picLink:String){
        let currentUser = DataService.ds.REF_USER_CURRENT
        currentUser.child("UserName").setValue(txtUserName.text)
        currentUser.child("FullName").setValue(txtFullName.text)
        currentUser.child("ProfileImage").setValue(picLink)
    }
    
    func showErrorAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

}

extension RegisterVC{
    func uploadImage(image: UIImage){
        guard let imageData = UIImageJPEGRepresentation(image, 0.2)else{
            print("Count not get JPEG representation of UIImage")
            return
        }
        
        let urlStr = IMAGESHACK_URL
        let url = NSURL(string: urlStr)!
        let keyData = IMAGESHACK_API_KEY.dataUsingEncoding(NSUTF8StringEncoding)!
        let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
        
        Alamofire.upload(.POST, url, multipartFormData: {
            multipartFormData in
            multipartFormData.appendBodyPart(data: imageData, name: "fileupload", fileName:"image", mimeType: "image/jpg")
            multipartFormData.appendBodyPart(data: keyData, name: "key")
            multipartFormData.appendBodyPart(data: keyJSON, name: "format")
        }){
            encodingResult in
            
            switch encodingResult{
            case .Success(let upload, _,_):
                upload.validate()
                upload.responseJSON {
                    response in
                    guard response.result.isSuccess else{
                        print("Error while uploading file: \(response.result.error)")
                        return
                    }
                    if let info = response.result.value as? Dictionary<String, AnyObject>{
                        print("In RESULT")
                        if let links = info["links"] as? Dictionary<String, AnyObject>{
                            if let imgLink = links["image_link"] as? String{
                                print("LINK: \(imgLink)")
                                self._userPicLink = imgLink
                            }//end if let imgLink
                        }//end if let links
                    }//end if let info
                    
                }//end case success
                
            case .Failure(let encodingError):
                print(encodingError)
                
            }//end switch
        }
    }
    
    func uploadImaggaImage(image:UIImage, progress: (percent: Float) -> Void,
                           completion: (tags: [String]) -> Void){
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else{
            print("Could not get JPEG representation of UIImage")
            return
        }
        Alamofire.upload(ImaggaRouter.Content,
         multipartFormData: { multipartFormData in
            multipartFormData.appendBodyPart(data: imageData, name: "imagefile", fileName: "image.jpg", mimeType: "image/jpeg")
            },
         encodingCompletion: {encodingResult in
            switch encodingResult{
            case .Success(let upload, _,_):
                upload.progress {bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                    dispatch_async(dispatch_get_main_queue()){
                        let percent = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
                        progress(percent: percent)
                    }//end dispatch async
                }//end upload.progress
                upload.validate()
                upload.responseJSON{ response in
                    guard response.result.isSuccess else{
                        print("Error while uploading file: \(response.result.error)")
                        completion(tags: [String]())
                        return
                    }
                    guard let responseJSON =
                        response.result.value as? [String: AnyObject],
                        uploadedFiles = responseJSON["uploaded"] as? [AnyObject],
                        firstFile = uploadedFiles.first as? [String: AnyObject],
                        firstFileID = firstFile["id"] as? String else{
                            print("Invalid information received from service")
                            completion(tags: [String]())
                            return
                    }
                    
                    print("Content uploaded with ID: \(firstFileID)")
                    
                    self.downloadTags(firstFileID){ tags in
                            completion(tags: tags)
                    }//end self.downloadTags completion
                    
            }//end upload.responseJSON
            case .Failure(let encodingError): print(encodingError)
            }//end switch statement
        })//end Alamofire.upload
        
    }
    
    func downloadTags(contentID: String, completion: ([String]) -> Void){
        Alamofire.request( ImaggaRouter.Tags(contentID) )
            .responseJSON{ response in
                guard response.result.isSuccess else {
                    print("Error while fetching tags: \(response.result.error)")
                    completion([String]())
                    return
                }// end guard
                
                guard let responseJSON = response.result.value as? [String: AnyObject],
                    results = responseJSON["results"] as? [AnyObject],
                    firstResult = results.first,
                    tagsAndConfidences = firstResult["tags"] as? [[String: AnyObject]]  else{
                        print("Invalid tag information received from service")
                        completion([String]())
                        return
                }//end guard
                print(responseJSON)
                let tags = tagsAndConfidences.flatMap({ dict in
                    return dict["tag"] as? String
                })
                
                completion(tags)
                
                let currentUserTags = DataService.ds.REF_USER_CURRENT.child("tags")
                    for i in 0..<self.tags!.count{
                        currentUserTags.child("tag\(i)").setValue(self.tags![i])
                        if self.tags![i] == "female" || self.tags![i] == "women" || self.tags![i] == "lady"{
                            self.currentUser.child("Gender").setValue("female")
                        }
                        if self.tags![i] == "man" || self.tags![i] == "men" || self.tags![i] == "male" || self.tags![i] == "guy" {
                            self.currentUser.child("Gender").setValue("male")
                        }
                        if self.tags![i] == "brunette"{
                            self.currentUser.child("HairColor").setValue("brunette")
                        }
                        if self.tags![i] == "causcasian"{
                            self.currentUser.child("Ethnicity").setValue("caucasian")
                        }
                    }
                //print("The number of tags in the tags array is: \(tags.count)")
                self.performSegueWithIdentifier("registered", sender: nil)       
        }//end .responseJSON
    }//end func downloadTags


    
}//end extension

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
        uploadImage(image)
        imgProfilePic.image = image
        imgCameraIcon.hidden = true
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}//end extension
