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
    var roomID: String!
    var roomName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        progressView.hidden = true
        activityIndicatorView.hidden = true
        
        title = roomName
        
        tableView.estimatedRowHeight = 375
        
        fetchCurrentUser()
        fetchPosts()
    }
    
    func fetchCurrentUser(){
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
    }
    
    func fetchPosts(){
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
            uploadFirebaseImage(unwrappedImage)
        }
         else if let postedText = postField.text where postedText != ""{
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
                img = PostsVC.imageCache.objectForKey(url) as? UIImage
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
       func uploadFirebaseImage(image: UIImage){
        let imageName = NSUUID().UUIDString
        let storageRef = FIRStorage.storage().reference().child("post_images").child("\(imageName).jpg")
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2){
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error.debugDescription)
                    return
                }
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                    self.postToFirebase(profileImageUrl)
                    self.activityIndicatorView.hidden = true
                }
            })
        }

    }
    func postToFirebase(imgURL: String?){
        //let currentUserName: String!
        let timestamp: NSNumber = NSDate().timeIntervalSince1970
        let authorID = FIRAuth.auth()!.currentUser!.uid
        let toRoom = roomID
        
        var post: Dictionary<String, AnyObject> = [
            "Description": postField.text!,
            "Likes": 0,
            "Author": currentUserName,
            "AuthorPic": currentProfilePicURL,
            "AuthorID" : authorID,
            "timestamp": timestamp,
            "toRoom" : toRoom
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
