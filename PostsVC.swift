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
    
    var roomsController: RoomsViewController?
    var cellID = "cellID"
    var postedImage: UIImage?
    var currentUserName: String!
    var currentProfilePicURL: String!
    var roomID: String!
    var roomName: String!
    
    var postsArray = [UserPost]()
    
    
    let topView: MaterialView = {
        let view = MaterialView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.whiteColor()
        return view
    }()
    
    let postTextField: MaterialTextField = {
        let ptf = MaterialTextField()
            ptf.placeholder = "What's on your mind?"
            ptf.translatesAutoresizingMaskIntoConstraints = false
        return ptf
    }()
    
    lazy var imageSelectorView: UIImageView = {
        let isv = UIImageView()
            isv.translatesAutoresizingMaskIntoConstraints = false
            isv.image = UIImage(named: "cameraIcon")
            isv.contentMode = .ScaleAspectFill
            isv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickPhoto)))
            isv.userInteractionEnabled = true
        return isv
    }()
    
    lazy var postButton: MaterialButton = {
        let pb = MaterialButton()
            pb.translatesAutoresizingMaskIntoConstraints = false
            pb.setTitle("Post", forState: .Normal)
        pb.addTarget(self, action: #selector(handlePostButtonTapped), forControlEvents: .TouchUpInside)
        return pb
    }()
    
    func handlePostButtonTapped(){
        if let unwrappedImage = postedImage{
            uploadFirebaseImage(unwrappedImage)
        }
        else if let postedText = postTextField.text where postedText != ""{
            self.postToFirebase(nil)
        }
    }
    
    let postTableView: UITableView = {
        let ptv = UITableView()
            ptv.translatesAutoresizingMaskIntoConstraints = false
            ptv.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        return ptv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.addSubview(topView)
        view.addSubview(postTableView)
        postTableView.delegate = self
        postTableView.dataSource = self
        postTableView.registerClass(testPostCell.self, forCellReuseIdentifier: "cellID")
        setupTopView()
        setupPostTableView()
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
                        let post = UserPost()
                            post.setValuesForKeysWithDictionary(postDict)
                        self.postsArray.insert(post, atIndex: 0)
                        print("Added to post array")
                    }
                }
            }
            
        })
        
        dispatch_async(dispatch_get_main_queue()){
            self.postTableView.reloadData()
        }
    }

    
    func setupTopView(){
        //need x, y, width and height constraints
        topView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        topView.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 24).active = true
        topView.widthAnchor.constraintEqualToAnchor(view.widthAnchor, constant: -16).active = true
        topView.heightAnchor.constraintEqualToConstant(45).active = true
        
        topView.addSubview(postTextField)
        topView.addSubview(imageSelectorView)
        topView.addSubview(postButton)
        
        postTextField.leftAnchor.constraintEqualToAnchor(topView.leftAnchor, constant: 8).active = true
        postTextField.centerYAnchor.constraintEqualToAnchor(topView.centerYAnchor).active = true
        postTextField.widthAnchor.constraintEqualToConstant(225).active = true
        postTextField.heightAnchor.constraintEqualToAnchor(topView.heightAnchor, constant: -16).active = true
        
        imageSelectorView.leftAnchor.constraintEqualToAnchor(postTextField.rightAnchor, constant: 8).active = true
        imageSelectorView.centerYAnchor.constraintEqualToAnchor(topView.centerYAnchor).active = true
        imageSelectorView.widthAnchor.constraintEqualToConstant(37).active = true
        imageSelectorView.heightAnchor.constraintEqualToAnchor(topView.heightAnchor, constant: -16).active = true
        
        postButton.leftAnchor.constraintEqualToAnchor(imageSelectorView.rightAnchor, constant: 8).active = true
        postButton.centerYAnchor.constraintEqualToAnchor(topView.centerYAnchor).active = true
        postButton.rightAnchor.constraintEqualToAnchor(topView.rightAnchor, constant: -8).active = true
        postButton.heightAnchor.constraintEqualToAnchor(topView.heightAnchor, constant: -16).active = true


    }
    
    func setupPostTableView(){
        postTableView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        postTableView.topAnchor.constraintEqualToAnchor(topView.bottomAnchor, constant: 8).active = true
        postTableView.widthAnchor.constraintEqualToAnchor(view.widthAnchor, constant: -16).active = true
        postTableView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
    }
    
    /*
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
 */
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
        imageSelectorView.image = postedImage
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}//end extension

extension PostsVC:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! testPostCell
        let post = postsArray[indexPath.row]
        cell.userPost = post
        return cell
        
        /*
         let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! UserCell
         let message = messagesArray[indexPath.row]
         cell.message = message
         return cell
 */
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 375
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let post = postsArray[indexPath.row]
//        
//        if post.imageURL == nil{
//            return 150
//        }else{
//            return tableView.estimatedRowHeight
//        }
//    }
    
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
                    
                }
            })
        }
        
    }
    func postToFirebase(imgURL: String?){
        
        let timestamp: NSNumber = NSDate().timeIntervalSince1970
        let authorID = FIRAuth.auth()!.currentUser!.uid
        let toRoom = roomID
        
        var post: Dictionary<String, AnyObject> = [
            "postText": postTextField.text!,
            "likes": 0,
            "fromID" : authorID,
            "timestamp": timestamp,
            "toRoom" : toRoom,
            "authorPic": currentProfilePicURL,
            "authorName": currentUserName,
        ]
        
        if imgURL != nil {
            post["showcaseImg"] = imgURL!
        }
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
            firebasePost.setValue(post)
        
        postTextField.text = ""
        imageSelectorView.image = UIImage(named: "cameraIcon")
        postedImage = nil
        
        dispatch_async(dispatch_get_main_queue()){
            self.postTableView.reloadData()
        }
    }
}//end extension

/*
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
*/



