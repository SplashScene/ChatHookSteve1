//
//  PostsVC.swift
//  driveby_Showcase
//
//  Created by Kevin Farm on 4/13/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class PostsVC: UIViewController{
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImage: UIImageView!
    
    var postsArray = [ChatPost]()
    static var imageCache = NSCache()
    
    var postedImage: UIImage?
    var currentUserName: String!
    var currentProfilePicURL: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        progressView.hidden = true
        activityIndicatorView.hidden = true
        
        
        tableView.estimatedRowHeight = 375
        let currentUser = DataService.ds.REF_USER_CURRENT
        
        currentUser.observeEventType(.Value, withBlock: {
            snapshot in
            if let myUserName = snapshot.value!.objectForKey("UserName"){
                self.currentUserName = myUserName as! String
            }
            if let myProfilePic = snapshot.value!.objectForKey("ProfileImage"){
                self.currentProfilePicURL = myProfilePic  as! String
            }
            
        })
        
        
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: {
            snapshot in
            
            self.postsArray = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    if let postDict = snap.value as? Dictionary<String, AnyObject>{
                        let key = snap.key
                        let post = ChatPost(postKey: key, dictionary: postDict)
                        self.postsArray.append(post)
                        print("Added to post array")
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    
    @IBAction func cameraImageTapped(sender: UITapGestureRecognizer) {
        self.pickPhoto()
    }
    
    @IBAction func postButtonTapped(sender: UIButton) {
        progressView.progress = 0.0
        progressView.hidden = false
        activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()
        
        if let unwrappedImage = postedImage{
            uploadImage(unwrappedImage, progress:{[unowned self] percent in
                self.progressView.setProgress(percent, animated: true)
                })
        } else if let postedText = postField.text where postedText != ""{
            self.postToFirebase(nil)
        }
    }
}//end class

extension PostsVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
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
        postedImage = image
        imageSelectorImage.image = postedImage
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}//end extension

extension PostsVC:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = postsArray[indexPath.row]
        print("ROW: \(indexPath.row) : \(post.postDescription) -> \(post.imageURL)")
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("ChatPostCell") as? ChatPostCell{
            cell.request?.cancel()
            var img: UIImage?
            
            if let url = post.imageURL{
                img = PostVC.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(post, img: img)
            return cell
        }else{
            return ChatPostCell()
        }
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = postsArray[indexPath.row]
        
        if post.imageURL == nil{
            return 150
        }else{
            return tableView.estimatedRowHeight
        }
    }
    
}//end extension

extension PostsVC{
    func uploadImage(image: UIImage, progress: (percent: Float) -> Void)  {
        guard let imageData = UIImageJPEGRepresentation(image, 0.2)else{
            print("Count not get JPEG representation of UIImage")
            return
        }
        
        let urlStr = IMAGESHACK_URL
        let url = NSURL(string: urlStr)!
        let keyData = IMAGESHACK_API_KEY.dataUsingEncoding(NSUTF8StringEncoding)!
        let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
        
        Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
            multipartFormData.appendBodyPart(data: imageData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
            multipartFormData.appendBodyPart(data: keyData, name: "key")
            multipartFormData.appendBodyPart(data: keyJSON, name: "format")
        }) { encodingResult in
            switch encodingResult{
            case .Success(let upload, _, _):
                upload.progress {bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                    dispatch_async(dispatch_get_main_queue()){
                        let percent = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
                        progress(percent: percent)
                    }
                }
                upload.validate()
                upload.responseJSON {response in
                    guard response.result.isSuccess else{
                        print("Error while uploading file: \(response.result.error)")
                        return
                    }
                    if let info = response.result.value as? Dictionary<String, AnyObject>{
                        
                        if let links = info["links"] as? Dictionary<String, AnyObject>{
                            if let imgLink = links["image_link"] as? String{
                                print("LINK: \(imgLink)")
                                self.postToFirebase(imgLink)
                            }//end if let imgLink
                        }//end if let links
                        
                    }//end if let info
                }
                
            case .Failure(let encodingError):
                print(encodingError)
            }//end switch
            self.progressView.hidden = true
            self.activityIndicatorView.stopAnimating()
            
        }
        
    }
    
    func postToFirebase(imgURL: String?){
        //let currentUserName: String!
        
        var post: Dictionary<String, AnyObject> = [
            "Description": postField.text!,
            "Likes": 0,
            "Author": currentUserName,
            "AuthorPic": currentProfilePicURL
        ]
        
        if imgURL != nil {
            post["PostURL"] = imgURL!
        }
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        postField.text = ""
        imageSelectorImage.image = UIImage(named: "cameraIcon")
        postedImage = nil
        
        tableView.reloadData()
    }
}//end extension
