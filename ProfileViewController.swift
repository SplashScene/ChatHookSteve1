//
//  ProfileViewController.swift
//  ChatHook
//
//  Created by Kevin Farm on 9/12/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import MobileCoreServices
import Firebase
import FirebaseStorage

class ProfileViewController: UIViewController {
    var collectionView: UICollectionView!
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var currentUserRef = DataService.ds.REF_USER_CURRENT
    var currentUser: User?
    var photoChoice: String?
    var galleryArray = [GalleryImage]()
    var timer: NSTimer?
    var selectedUser: User?
    
    
    let backgroundImageView: UIImageView = {
        let backImageView = UIImageView()
            backImageView.translatesAutoresizingMaskIntoConstraints = false
            backImageView.image = UIImage(named: "background1")
            backImageView.contentMode = .ScaleAspectFill
        return backImageView
    }()
    
    lazy var addPhotoButton: UIButton = {
        let btnImage = UIImage(named: "add_photo_btn")
        let addPicBtn = UIButton()
            addPicBtn.translatesAutoresizingMaskIntoConstraints = false
            addPicBtn.setImage(btnImage, forState: .Normal)
            addPicBtn.addTarget(self, action: #selector(handleAddPhotoButtonTapped), forControlEvents: .TouchUpInside)
        return addPicBtn
    }()
    
    
    
    lazy var profileImageView: MaterialImageView = {
        let imageView = MaterialImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
            imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
     
    let currentUserNameLabel: UILabel = {
        let nameLabel = UILabel()
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            nameLabel.alpha = 1.0
            nameLabel.font = UIFont(name: "Avenir Medium", size:  18.0)
            nameLabel.backgroundColor = UIColor.clearColor()
            nameLabel.textColor = UIColor.whiteColor()
            nameLabel.sizeToFit()
            nameLabel.textAlignment = NSTextAlignment.Center
        return nameLabel
    }()
    
    let addPhotosToGalleryLabel: UILabel = {
        let galleryLabel = UILabel()
            galleryLabel.translatesAutoresizingMaskIntoConstraints = false
            galleryLabel.hidden = false
            galleryLabel.font = UIFont(name: "Avenir Medium", size:  18.0)
            galleryLabel.backgroundColor = UIColor.clearColor()
            galleryLabel.textColor = UIColor.whiteColor()
            galleryLabel.sizeToFit()
            galleryLabel.textAlignment = NSTextAlignment.Center
            galleryLabel.text = "Add Photos to Your Gallery"
        return galleryLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenSize = UIScreen.mainScreen().bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        view.addSubview(backgroundImageView)
        view.addSubview(addPhotoButton)
        
        if selectedUser != nil{
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(handleCancel))
        }

        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
            //layout.itemSize = CGSize(width: 90, height: 120)
            layout.itemSize = CGSize(width: screenWidth / 5, height: 120)
        
        let frame = CGRectMake(0, view.center.y, view.frame.width, view.frame.height / 2)
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        collectionView.addSubview(addPhotosToGalleryLabel)
        
        addPhotosToGalleryLabel.centerXAnchor.constraintEqualToAnchor(collectionView.centerXAnchor).active = true
        addPhotosToGalleryLabel.centerYAnchor.constraintEqualToAnchor(collectionView.centerYAnchor).active = true
        
        self.view.addSubview(collectionView)
        
        collectionView!.registerClass(GalleryCollectionCell.self, forCellWithReuseIdentifier: "Cell")
        
        
        
        if selectedUser == nil{
            guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
            fetchCurrentUser()
            observeGallery(uid)
        }else{
            setupSelectedUserProfile()
            observeGallery((selectedUser?.postKey)!)
            addPhotosToGalleryLabel.text = "No Photos in Gallery"
            addPhotoButton.hidden = true
        }

        setupBackgroundImageView()
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
    }
    
    func handleCancel(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handleAddPhotoButtonTapped(){
        
            let alertController = UIAlertController(title: "Edit/Add Photo", message: "Do you want to add to gallery or edit your profile picture", preferredStyle: .Alert)
            let buttonOne = UIAlertAction(title: "Edit Profile Picture", style: .Default) { (action) in
                self.photoChoice = "Profile"
                self.pickPhoto()
            }
            let buttonTwo = UIAlertAction(title: "Add to Photo Gallery", style: .Default) { (action) in
                self.photoChoice = "Gallery"
                self.pickPhoto()
            }
            let buttonCancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                print("Inside Cancel")
            }
            
            alertController.addAction(buttonOne)
            alertController.addAction(buttonTwo)
            alertController.addAction(buttonCancel)
            
            presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func getMediaFrom(type: CFString){
        let mediaPicker = UIImagePickerController()
            mediaPicker.delegate = self
            mediaPicker.mediaTypes = [type as String]
        
        presentViewController(mediaPicker, animated: true, completion: nil)
    }

    
    func fetchCurrentUser(){
        currentUserRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let currentUserPostKey = snapshot.key
                    self.currentUser = User(postKey: currentUserPostKey, dictionary: dictionary)
                        self.profileImageView.loadImageUsingCacheWithUrlString((self.currentUser?.profileImageUrl)!)
                        self.currentUserNameLabel.text = self.currentUser?.userName
                        self.navigationItem.title = self.currentUser?.userName
                }
            }, withCancelBlock: nil)
    }
    
    func setupSelectedUserProfile(){
        self.profileImageView.loadImageUsingCacheWithUrlString((self.selectedUser?.profileImageUrl)!)
        self.currentUserNameLabel.text = self.selectedUser?.userName
        self.navigationItem.title = self.selectedUser?.userName

    }
    
    func observeGallery(uid: String){
        //guard let uid = FIRAuth.auth()?.currentUser!.uid else { return }
        let userGalleryPostRef = DataService.ds.REF_USERS_GALLERY.child(uid)
        
        userGalleryPostRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let galleryId = snapshot.key
            let galleryPostRef = DataService.ds.REF_GALLERYIMAGES.child(galleryId)
            
            galleryPostRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject]{
                        let galleryPost = GalleryImage(key: snapshot.key)
                            galleryPost.setValuesForKeysWithDictionary(dictionary)
                        self.galleryArray.append(galleryPost)
                        
                        self.timer?.invalidate()
                        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.handleReloadGallery), userInfo: nil, repeats: false)
                    }
                }, withCancelBlock: nil)
            }, withCancelBlock: nil)
    }
    
    func handleReloadGallery(){
        dispatch_async(dispatch_get_main_queue()){
            self.collectionView.reloadData()
        }
    }
    
    func setupBackgroundImageView(){
        backgroundImageView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        backgroundImageView.heightAnchor.constraintEqualToAnchor(view.heightAnchor, multiplier: 0.5).active = true
        backgroundImageView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        
        //backgroundImageView.addSubview(addPhotoButton)
        backgroundImageView.addSubview(profileImageView)
        backgroundImageView.addSubview(currentUserNameLabel)
        
        
        profileImageView.centerXAnchor.constraintEqualToAnchor(backgroundImageView.centerXAnchor).active = true
        profileImageView.centerYAnchor.constraintEqualToAnchor(backgroundImageView.centerYAnchor).active = true
        profileImageView.widthAnchor.constraintEqualToConstant(150).active = true
        profileImageView.heightAnchor.constraintEqualToConstant(150).active = true
        
        currentUserNameLabel.centerXAnchor.constraintEqualToAnchor(backgroundImageView.centerXAnchor).active = true
        currentUserNameLabel.topAnchor.constraintEqualToAnchor(profileImageView.bottomAnchor, constant: 8).active = true
        
        addPhotoButton.centerXAnchor.constraintEqualToAnchor(profileImageView.rightAnchor, constant: 24).active = true
        addPhotoButton.centerYAnchor.constraintEqualToAnchor(profileImageView.centerYAnchor).active = true
        addPhotoButton.widthAnchor.constraintEqualToConstant(40).active = true
        addPhotoButton.heightAnchor.constraintEqualToConstant(40).active = true

   
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func setupCollectionView(){
        collectionView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingView: UIView?
    
    func performZoomInForStartingImageView(startingView: UIView, photoImage: UIImageView){
        self.startingView = startingView
        
        startingFrame = startingView.superview?.convertRect(startingView.frame, toView: nil)
        
        let zoomingView = UIImageView(frame: startingFrame!)
            zoomingView.backgroundColor = UIColor.redColor()
            zoomingView.userInteractionEnabled = true
            zoomingView.contentMode = .ScaleAspectFill
            zoomingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
            zoomingView.image = photoImage.image
        if let keyWindow = UIApplication.sharedApplication().keyWindow{
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
                
                }, completion: { (completed) in
                    zoomOutImageView.removeFromSuperview()
                    self.startingView?.hidden = false
            })
        }
    }
   
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        addPhotosToGalleryLabel.hidden = galleryArray.count > 0
        
        let galleryImage = galleryArray[indexPath.item]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! GalleryCollectionCell
        cell.gallery = galleryImage
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath),
           let cellImageView = cell.contentView.subviews[0] as? UIImageView{
            
            performZoomInForStartingImageView(cell.contentView, photoImage: cellImageView)
            
        }
    }
}


