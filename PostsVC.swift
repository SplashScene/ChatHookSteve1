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
import MobileCoreServices
import AVFoundation


class PostsVC: UIViewController{
    
    var roomsController: RoomsViewController?
    var cellID = "cellID"
    var postedImage: UIImage?
    var postedVideo: NSURL?
    var postedText: String?
    var currentUserName: String!
    var currentProfilePicURL: String!
    var messageImage: UIImage?
    var parentRoom: PublicRoom?
    var timer: NSTimer?
    
    
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
            isv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageSelector)))
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

    
    func handleImageSelector(){
        let sheet = UIAlertController(title: "Media Messages", message: "Please select a media", preferredStyle: .ActionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (alert:UIAlertAction) in
            sheet.dismissViewControllerAnimated(true, completion: nil)
        }
        let photoLibary = UIAlertAction(title: "Photo Library", style: .Default) { (alert: UIAlertAction) in
            self.getMediaFrom(kUTTypeImage)
        }
        
        let videoLibrary = UIAlertAction(title: "Video Library", style: .Default) { (alert: UIAlertAction) in
            self.getMediaFrom(kUTTypeMovie)
        }
        
        sheet.addAction(photoLibary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
        self.presentViewController(sheet, animated: true, completion: nil)

    }
    
    private func getMediaFrom(type: CFString){
        let mediaPicker = UIImagePickerController()
            mediaPicker.delegate = self
            mediaPicker.mediaTypes = [type as String]
        
        presentViewController(mediaPicker, animated: true, completion: nil)
    }
    
    func handlePostButtonTapped(){
        postedText = postTextField.text
        
        if let unwrappedImage = postedImage{
            uploadToFirebaseStorageUsingSelectedMedia(unwrappedImage, video: nil, completion: { (imageUrl) in
                self.enterIntoPostsAndPostsPerRoomDatabaseWithImageUrl("image/jpg", postText: self.postedText, thumbnailURL: nil, fileURL: imageUrl)
                //self.enterIntoPostsAndPostsPerRoomDatabaseWithImageUrl("image/jpg", thumbnailURL: nil, fileURL:imageUrl)
            })

        }else if let unwrappedVideo = postedVideo{
            
            uploadToFirebaseStorageUsingSelectedMedia(nil, video: unwrappedVideo, completion: { (imageUrl) in
//                self.enterIntoPostsAndPostsPerRoomDatabaseWithImageUrl("video/mp4", postText: self.postedText, thumbnailURL: nil, fileURL: imageUrl)
                //self.enterIntoPostsAndPostsPerRoomDatabaseWithImageUrl("video/mp4",thumbnailURL: nil, fileURL:imageUrl)
            })
        }else{
            self.enterIntoPostsAndPostsPerRoomDatabaseWithImageUrl("text", postText: postedText, thumbnailURL: nil, fileURL: nil)
        }
        
        
    }
    
    let postTableView: UITableView = {
        let ptv = UITableView()
            ptv.translatesAutoresizingMaskIntoConstraints = false
            ptv.backgroundColor = UIColor(r: 220, g: 220, b: 220)
            ptv.allowsSelection = false
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
        postTableView.estimatedRowHeight = 350
        
        setupTopView()
        setupPostTableView()
        setupNavBarWithUserOrProgress(nil)
        fetchCurrentUser()
        observePosts()
    }
    
    func handleBack(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func fetchCurrentUser(){
        let currentUser = DataService.ds.REF_USER_CURRENT
        
        currentUser.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    self.currentUserName = dictionary["UserName"] as! String
                    self.currentProfilePicURL = dictionary["ProfileImage"] as! String
                }
            }, withCancelBlock: nil)
    }
    
    
    func setupNavBarWithUserOrProgress(progress:String?){
        
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
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if let progressText = progress{
            nameLabel.text = progressText
            nameLabel.textColor = UIColor.redColor()
        }else{
            nameLabel.text = parentRoom?.RoomName
            nameLabel.textColor = UIColor.darkGrayColor()
        }
        
        containerView.addSubview(nameLabel)
        
        nameLabel.leftAnchor.constraintEqualToAnchor(profileImageView.rightAnchor, constant: 8).active = true
        nameLabel.centerYAnchor.constraintEqualToAnchor(profileImageView.centerYAnchor).active = true
        nameLabel.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        nameLabel.heightAnchor.constraintEqualToAnchor(profileImageView.heightAnchor).active = true
        
        containerView.centerXAnchor.constraintEqualToAnchor(titleView.centerXAnchor).active = true
        containerView.centerYAnchor.constraintEqualToAnchor(titleView.centerYAnchor).active = true
        
        self.navigationItem.titleView = titleView
    }

    func observePosts(){
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
                
                    self.timer?.invalidate()
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.handleReloadPosts), userInfo: nil, repeats: false)
                
                },
                withCancelBlock: nil)
            }, withCancelBlock: nil)
    }
    
    func handleReloadPosts(){
        dispatch_async(dispatch_get_main_queue()){
            self.postTableView.reloadData()
        }
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
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingView: UIView?
    
    func performZoomInForStartingImageView(startingImageView: UIImageView){
        print("Performing zoom in logic in controller")
        startingFrame = startingImageView.superview?.convertRect(startingImageView.frame, toView: nil)
        print(startingFrame)
        let zoomingView = UIImageView(frame: startingFrame!)
            zoomingView.backgroundColor = UIColor.redColor()
            zoomingView.image = startingImageView.image
            zoomingView.userInteractionEnabled = true
            zoomingView.contentMode = .ScaleAspectFill
            zoomingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.sharedApplication().keyWindow{
            keyWindow.addSubview(zoomingView)
            
                blackBackgroundView = UIView(frame: keyWindow.frame)
                blackBackgroundView?.backgroundColor = UIColor.blackColor()
                blackBackgroundView?.alpha = 0
                keyWindow.addSubview(blackBackgroundView!)
                
                keyWindow.addSubview(zoomingView)
                
                UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {
                        self.blackBackgroundView!.alpha = 1
                        self.startingView?.hidden = true

                      let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                    
                        zoomingView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                        
                        zoomingView.center = keyWindow.center
                    }, completion: nil)
            
        }
  
    }

    func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomOutImageView = tapGesture.view{
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                //self.topView.alpha = 1
                }, completion: { (completed) in
                    zoomOutImageView.removeFromSuperview()
                    self.startingView?.hidden = false
            })
        }
    }

     
}//end class

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
            cell.postViewController = self
        
        if post.mediaType == "VIDEO"{
            setupVideoPostCell(cell)
        }
        
        return cell
    }
    
    private func setupVideoPostCell(cell: testPostCell){
//        
//        if cell.subviews.count > 0{
//            for view in (cell.subviews){
//                view.removeFromSuperview()
//            }
//        }
//        
        
        let playButton = PlayButton()
 
        cell.showcaseImageView.addSubview(playButton)
        
        playButton.centerXAnchor.constraintEqualToAnchor(cell.showcaseImageView.centerXAnchor).active = true
        playButton.centerYAnchor.constraintEqualToAnchor(cell.showcaseImageView.centerYAnchor).active = true
        playButton.widthAnchor.constraintEqualToConstant(50).active = true
        playButton.heightAnchor.constraintEqualToConstant(50).active = true
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            activityIndicatorView.hidesWhenStopped = true
        
        
        cell.showcaseImageView.addSubview(activityIndicatorView)
        
        activityIndicatorView.centerXAnchor.constraintEqualToAnchor(cell.showcaseImageView.centerXAnchor).active = true
        activityIndicatorView.centerYAnchor.constraintEqualToAnchor(cell.showcaseImageView.centerYAnchor).active = true
        activityIndicatorView.widthAnchor.constraintEqualToConstant(50).active = true
        activityIndicatorView.heightAnchor.constraintEqualToConstant(50).active = true
    }

    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = postsArray[indexPath.row]
        if post.showcaseUrl == nil{
            return 100
        }else{
            return tableView.estimatedRowHeight
        }
    }
    
}//end extension


extension PostsVC{
    private func uploadToFirebaseStorageUsingSelectedMedia(image: UIImage?, video: NSURL?, completion: (imageUrl: String) -> ()){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        let imageName = NSUUID().UUIDString
        
        if let picture = image{
            let ref = FIRStorage.storage().reference().child("post_images").child(uid).child("photos").child(imageName)
            if let uploadData = UIImageJPEGRepresentation(picture, 0.2){
                let metadata = FIRStorageMetadata()
                    metadata.contentType = "image/jpg"
                let uploadTask = ref.putData(uploadData, metadata: metadata, completion: { (metadata, error) in
                    if error != nil{
                        print(error.debugDescription)
                        return
                    }
                    
                    if let imageUrl = metadata?.downloadURL()?.absoluteString{
                        completion(imageUrl: imageUrl)
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
            
        } else if let movie = video {
            print("INSIDE MOVIE SECTION OF THE UPLOAD")
            let ref = FIRStorage.storage().reference().child("post_images").child(uid).child("videos").child(imageName)
            if let uploadData = NSData(contentsOfURL: movie){
                let metadata = FIRStorageMetadata()
                    metadata.contentType = "video/mp4"
                let uploadTask = ref.putData(uploadData, metadata: metadata, completion: { (metadata, error) in
                    if error != nil{
                        print(error.debugDescription)
                        return
                    }
                    
                    if let videoUrl = metadata?.downloadURL()?.absoluteString{
                        print("Inside videoUrl")
                        if let thumbnailImage = self.thumbnailImageForVideoUrl(movie){
                            print("Inside Thumbnail Image")
                            self.uploadToFirebaseStorageUsingSelectedMedia(thumbnailImage, video: nil, completion: { (imageUrl) in
                                imageCache.setObject(thumbnailImage, forKey: videoUrl)
                                self.enterIntoPostsAndPostsPerRoomDatabaseWithImageUrl(metadata!.contentType!, postText: self.postedText, thumbnailURL: imageUrl, fileURL: videoUrl)
                                self.imageSelectorView.loadImageUsingCacheWithUrlString(imageUrl)
                            })
                        }
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
    
    private func enterIntoPostsAndPostsPerRoomDatabaseWithImageUrl(metadata: String, postText: String?, thumbnailURL: String?, fileURL: String?){
        guard let uid = FIRAuth.auth()?.currentUser!.uid else { return }
        let toRoom = parentRoom?.postKey
        let itemRef = DataService.ds.REF_POSTS.childByAutoId()
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        var messageItem: Dictionary<String,AnyObject>
        
        if metadata == "video/mp4"{
            messageItem = ["fromId": uid,
                           "timestamp" : timestamp,
                           "toRoom": toRoom!,
                           "mediaType": "VIDEO",
                           "thumbnailUrl": thumbnailURL!,
                           "likes": 0,
                           "showcaseUrl": fileURL!,
                           "authorName": currentUserName,
                           "authorPic": currentProfilePicURL]
        }else if metadata == "image/jpg"{
            messageItem = ["fromId": uid,
                           "timestamp" : timestamp,
                           "toRoom": toRoom!,
                           "mediaType": "PHOTO",
                           "likes": 0,
                           "showcaseUrl": fileURL!,
                           "authorName": currentUserName,
                           "authorPic": currentProfilePicURL]
        }else{
            messageItem = ["fromId": uid,
                           "timestamp" : timestamp,
                           "toRoom": toRoom!,
                           "mediaType": "TEXT",
                           "likes": 0,
                           "authorName": currentUserName,
                           "authorPic": currentProfilePicURL]
        }
        
        if let unwrappedText = postText{
            messageItem["postText"] = unwrappedText
        }
        
        
        itemRef.updateChildValues(messageItem) { (error, ref) in
            if error != nil {
                print(error?.description)
                return
            }
            
            let postRoomRef = DataService.ds.REF_BASE.child("posts_per_room").child(self.parentRoom!.postKey!)
            
            let postID = itemRef.key
                postRoomRef.updateChildValues([postID: 1])
        }
        
        self.postTextField.text = ""
        self.imageSelectorView.image = UIImage(named: "cameraIcon")
        self.postedImage = nil
        self.postedVideo = nil
        self.postedText = nil
    }
    
    private func thumbnailImageForVideoUrl(videoUrl: NSURL) -> UIImage?{
        print(videoUrl)
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
    
 }//end extension




