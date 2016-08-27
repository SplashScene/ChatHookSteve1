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
import FirebaseStorage


class PostsVC: UIViewController{
    
    var roomsController: RoomsViewController?
    var cellID = "cellID"
    var postedImage: UIImage?
    var currentUserName: String!
    var currentProfilePicURL: String!
    var messageImage: UIImage?
    var parentRoom: PublicRoom?
    
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
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(handleBack))
        view.addSubview(topView)
        view.addSubview(postTableView)
        postTableView.delegate = self
        postTableView.dataSource = self
        postTableView.registerClass(testPostCell.self, forCellReuseIdentifier: "cellID")
        postTableView.estimatedRowHeight = 350
        setupTopView()
        setupPostTableView()
        setupNavBarWithRoom()
        fetchCurrentUser()
        fetchPosts()
    }
    
    func handleBack(){
        dismissViewControllerAnimated(true, completion: nil)
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
    
    
     func setupNavBarWithRoom(){
     
     let titleView = UIView()
     titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
     
     let containerView = UIView()
     containerView.translatesAutoresizingMaskIntoConstraints = false
     
     titleView.addSubview(containerView)
     
     let profileImageView = UIImageView()
         profileImageView.translatesAutoresizingMaskIntoConstraints = false
         profileImageView.contentMode = .ScaleAspectFill
         profileImageView.layer.cornerRadius = 20
         profileImageView.clipsToBounds = true
         profileImageView.image = messageImage
     
     containerView.addSubview(profileImageView)
     
     profileImageView.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
     profileImageView.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
     profileImageView.widthAnchor.constraintEqualToConstant(40).active = true
     profileImageView.heightAnchor.constraintEqualToConstant(40).active = true
     
     let nameLabel = UILabel()
         nameLabel.text = parentRoom?.RoomName
         nameLabel.translatesAutoresizingMaskIntoConstraints = false
     
     containerView.addSubview(nameLabel)
     
     nameLabel.leftAnchor.constraintEqualToAnchor(profileImageView.rightAnchor, constant: 8).active = true
     nameLabel.centerYAnchor.constraintEqualToAnchor(profileImageView.centerYAnchor).active = true
     nameLabel.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
     nameLabel.heightAnchor.constraintEqualToAnchor(profileImageView.heightAnchor).active = true
     
     containerView.centerXAnchor.constraintEqualToAnchor(titleView.centerXAnchor).active = true
     containerView.centerYAnchor.constraintEqualToAnchor(titleView.centerYAnchor).active = true
     
     self.navigationItem.titleView = titleView
     }

 
    
    func fetchPosts(){
        guard let roomID = parentRoom?.postKey else { return }
        let roomPostsRef = DataService.ds.REF_POSTSPERROOM.child(roomID)
        
        roomPostsRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let postID = snapshot.key
            let postsRef = DataService.ds.REF_POSTS.child(postID)
            
            postsRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                
                let post = UserPost(key: snapshot.key)
                    post.setValuesForKeysWithDictionary(dictionary)
                    self.postsArray.insert(post, atIndex: 0)
                
                    dispatch_async(dispatch_get_main_queue()){
                        self.postTableView.reloadData()
                    }
                },
                withCancelBlock: nil)
            }, withCancelBlock: nil)
    }

    
    func setupTopView(){
        //need x, y, width and height constraints
        topView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        topView.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 72).active = true
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
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = postsArray[indexPath.row]
        if post.showcaseImg == nil{
            return 100
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
                    
                }
            })
        }
        
    }
    func postToFirebase(imgURL: String?){
        
        let timestamp: NSNumber = NSDate().timeIntervalSince1970
        let authorID = FIRAuth.auth()!.currentUser!.uid
        let toRoom = parentRoom?.postKey
        
        var post: Dictionary<String, AnyObject> = [
            "postText": postTextField.text!,
            "likes": 0,
            "fromID" : authorID,
            "timestamp": timestamp,
            "toRoom" : toRoom!,
            "authorPic": currentProfilePicURL,
            "authorName": currentUserName,
        ]
        
        if imgURL != nil {
            post["showcaseImg"] = imgURL!
        }
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
            //firebasePost.setValue(post)
        
        firebasePost.updateChildValues(post) { (error, ref) in
            if error != nil{
                print(error?.description)
                return
            }
            
            let postRoomRef = DataService.ds.REF_BASE.child("posts_per_room").child(self.parentRoom!.postKey!)
            let postID = firebasePost.key
            
            postRoomRef.updateChildValues([postID: 1])
        }
        
        postTextField.text = ""
        imageSelectorView.image = UIImage(named: "cameraIcon")
        postedImage = nil
        
        dispatch_async(dispatch_get_main_queue()){
            self.postTableView.reloadData()
        }
    }
}//end extension




