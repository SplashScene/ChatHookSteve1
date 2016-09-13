//
//  ProfileViewController.swift
//  ChatHook
//
//  Created by Kevin Farm on 9/12/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    var collectionView: UICollectionView!
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var currentUserRef = DataService.ds.REF_USER_CURRENT
    var currentUser: User?
    
    let backgroundImageView: UIImageView = {
        let backImageView = UIImageView()
            backImageView.translatesAutoresizingMaskIntoConstraints = false
            backImageView.image = UIImage(named: "background1")
            backImageView.contentMode = .ScaleAspectFill
        return backImageView
    }()
    
    lazy var profileImageView: MaterialImageView = {
        let imageView = MaterialImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
            imageView.translatesAutoresizingMaskIntoConstraints = false
        //imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickPhoto)))
            //imageView.userInteractionEnabled = true
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenSize = UIScreen.mainScreen().bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        view.addSubview(backgroundImageView)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.itemSize = CGSize(width: screenWidth / 4, height: 120)
        
        let frame = CGRectMake(0, view.center.y, view.frame.width, view.frame.height / 2)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        self.view.addSubview(collectionView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchCurrentUser()
        setupBackgroundImageView()
    }
    
    func fetchCurrentUser(){
        currentUserRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let currentUserPostKey = snapshot.key
                    self.currentUser = User(postKey: currentUserPostKey, dictionary: dictionary)
                        self.profileImageView.loadImageUsingCacheWithUrlString((self.currentUser?.profileImageUrl)!)
                        self.currentUserNameLabel.text = self.currentUser?.userName
                }
            }, withCancelBlock: nil)
    }
    
    func setupBackgroundImageView(){
        backgroundImageView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        backgroundImageView.heightAnchor.constraintEqualToAnchor(view.heightAnchor, multiplier: 0.5).active = true
        backgroundImageView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        
        backgroundImageView.addSubview(profileImageView)
        backgroundImageView.addSubview(currentUserNameLabel)
        
        profileImageView.centerXAnchor.constraintEqualToAnchor(backgroundImageView.centerXAnchor).active = true
        profileImageView.centerYAnchor.constraintEqualToAnchor(backgroundImageView.centerYAnchor, constant: -24).active = true
        profileImageView.widthAnchor.constraintEqualToConstant(150).active = true
        profileImageView.heightAnchor.constraintEqualToConstant(150).active = true
        
        currentUserNameLabel.centerXAnchor.constraintEqualToAnchor(backgroundImageView.centerXAnchor).active = true
        currentUserNameLabel.topAnchor.constraintEqualToAnchor(profileImageView.bottomAnchor, constant: 8).active = true
   
    }
    
    func setupCollectionView(){
        collectionView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
    }
   
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 14
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.orangeColor()
        return cell
    }
}
