//
//  testPostCell.swift
//  ChatHook
//
//  Created by Kevin Farm on 8/24/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase

class testPostCell: UITableViewCell {
    var postViewController:PostsVC?
    var likeRef: FIRDatabaseReference!

    var userPost: UserPost?{
        didSet{
                likeRef = DataService.ds.REF_USER_CURRENT.child("Likes").child(userPost!.postKey!)
                let postRef = DataService.ds.REF_POSTS.child(userPost!.postKey!)
                    postRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject]{
                        
                        self.userNameLabel.text = dictionary["authorName"] as? String
                        self.descriptionText.text = dictionary["postText"] as? String
                        
                        if let numberOfLikes = dictionary["likes"] as? Int{
                            self.likeCount.text = String(numberOfLikes)
                            self.likesLabel.text = numberOfLikes == 1 ? "Like" : "Likes"
                        }
                        
                        if let profileImageUrl = dictionary["authorPic"] as? String {
                            self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                        }
                        if let postType = dictionary["mediaType"] as? String{
                            switch postType{
                                case "VIDEO":
                                    guard let videoThumbnail = dictionary["thumbnailUrl"] as? String else { return }
                                    self.showcaseImageView.loadImageUsingCacheWithUrlString(videoThumbnail)
                                case "PHOTO":
                                    guard let picImage = dictionary["showcaseUrl"] as? String else { return }
                                    self.showcaseImageView.loadImageUsingCacheWithUrlString(picImage)
                                default:
                                        self.showcaseImageView.image = nil
                            }
                        }
                      }
                    }, withCancelBlock: nil)
            
                    likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                        if let _ = snapshot.value as? NSNull{
                            //This means that we have not liked this specific post
                            let image = UIImage(named: "Like")
                            self.likeButton.setImage(image, forState: .Normal)
                            //self.likeImageView.image = UIImage(named: "Like")
                        }else{
                            let image = UIImage(named: "iLike")
                            self.likeButton.setImage(image, forState: .Normal)
                           // self.likeImageView.image = UIImage(named: "iLike")
                        }
                    })

            
            
            
//            if let seconds = userPost?.timestamp?.doubleValue{
//                let timestampDate = NSDate(timeIntervalSince1970: seconds)
//                let dateFormatter = NSDateFormatter()
//                    dateFormatter.dateFormat = "hh:mm:ss a"
//                timeLabel.text = dateFormatter.stringFromDate(timestampDate)
//            }
            
        }
    }

    var postLiked: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let cellContainerView: UIView = {
        let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.backgroundColor = UIColor.whiteColor()
            containerView.layer.cornerRadius = 5.0
            containerView.layer.masksToBounds = true
            containerView.sizeToFit()
        return containerView
    }()
    
    
    let profileImageView: MaterialImageView = {
        let imageView = MaterialImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 24
            imageView.layer.masksToBounds = true
            imageView.contentMode = .ScaleAspectFill
        return imageView
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.alpha = 1.0
            label.text = "User Name"
            label.font = UIFont(name: "Avenir Medium", size:  18.0)
            label.backgroundColor = UIColor.clearColor()
            label.textColor = UIColor.blueColor()
            label.sizeToFit()
        return label
    }()
    
    lazy var likeButton: UIButton = {
        let likeBtn = UIButton()
        let image = UIImage(named: "Like")
            likeBtn.setImage(image, forState: .Normal)
            likeBtn.translatesAutoresizingMaskIntoConstraints = false
            likeBtn.addTarget(self, action: #selector(handleLikeButtonTapped), forControlEvents: .TouchUpInside)
        return likeBtn
    }()

    
//    lazy var likeImageView: UIImageView = {
//        let imageView = UIImageView()
//            imageView.image = UIImage(named: "Like")
//            imageView.translatesAutoresizingMaskIntoConstraints = false
//            imageView.contentMode = .ScaleAspectFill
//            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(likeTapped)))
//            imageView.userInteractionEnabled = true
//        
//        return imageView
//    }()

    let timeLabel: UILabel = {
        let label = UILabel()
            label.text = "HH:MM:SS"
            label.font = UIFont.systemFontOfSize(12)
            label.textColor = UIColor.lightGrayColor()
            label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var likeCount: UILabel = {
        let label = UILabel()
            label.text = "0"
            label.font = UIFont(name: "Avenir Medium", size:  12.0)
            label.textColor = UIColor.darkGrayColor()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.sizeToFit()
        return label
    }()

    
    let likesLabel: UILabel = {
        let label = UILabel()
//            label.text = "Likes"
            label.font = UIFont(name: "Avenir Medium", size:  12.0)
            label.textColor = UIColor.darkGrayColor()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.sizeToFit()
        return label
    }()
    
    let descriptionText: UILabel = {
        let descripTextView = UILabel()
            descripTextView.translatesAutoresizingMaskIntoConstraints = false
            descripTextView.font = UIFont(name: "Avenir Medium", size:  14.0)
            descripTextView.textColor = UIColor.darkGrayColor()
            descripTextView.numberOfLines = 0
        return descripTextView
    }()

    
    /*
    let descriptionText: UITextView = {
        let descripTextView = UITextView()
            descripTextView.translatesAutoresizingMaskIntoConstraints = false
            descripTextView.text = "This is sample description text for the post"
            descripTextView.font = UIFont(name: "Avenir Medium", size:  14.0)
            descripTextView.textColor = UIColor.darkGrayColor()
            descripTextView.editable = false
            descripTextView.scrollEnabled = false
//        let fixedWidth = descripTextView.frame.size.width
//        descripTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
//        let newSize = descripTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
//        var newFrame = descripTextView.frame
//        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
//        descripTextView.frame = newFrame;
            //descripTextView.sizeToFit()
        return descripTextView
    }()
    */
    lazy var showcaseImageView: UIImageView = {
        let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .ScaleAspectFill
            imageView.layer.cornerRadius = 5
            imageView.layer.masksToBounds = true
            imageView.layer.shadowOpacity = 0.8
            imageView.layer.shadowRadius = 5.0
            imageView.layer.shadowOffset = CGSizeMake(2.0, 2.0)
            imageView.layer.shadowColor = UIColor.blackColor().CGColor
            imageView.userInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoom)))
        return imageView
    }()
    
    let separatorLineView: UIView = {
        let sepLineView = UIView()
            sepLineView.translatesAutoresizingMaskIntoConstraints = false
            sepLineView.backgroundColor = UIColor.darkGrayColor()
        return sepLineView
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        //self.layoutIfNeeded()
        //descriptionText.delegate = self
        
        cellContainerView.addSubview(profileImageView)
        cellContainerView.addSubview(userNameLabel)
        cellContainerView.addSubview(likeButton)
        //cellContainerView.addSubview(likeImageView)
        cellContainerView.addSubview(likeCount)
        cellContainerView.addSubview(likesLabel)
        cellContainerView.addSubview(descriptionText)
        cellContainerView.addSubview(showcaseImageView)
        cellContainerView.addSubview(separatorLineView)
        
        //need x, y, width, height anchors
        setupProfileImageUserNameLikes()
        setupDescriptionTextShowcaseImage()
        
            }
    
    func setupProfileImageUserNameLikes(){
        profileImageView.leftAnchor.constraintEqualToAnchor(cellContainerView.leftAnchor, constant: 8).active = true
        profileImageView.topAnchor.constraintEqualToAnchor(cellContainerView.topAnchor, constant: 8).active = true
        profileImageView.widthAnchor.constraintEqualToConstant(48).active = true
        profileImageView.heightAnchor.constraintEqualToConstant(48).active = true
        
        userNameLabel.leftAnchor.constraintEqualToAnchor(profileImageView.rightAnchor, constant: 8).active = true
        userNameLabel.centerYAnchor.constraintEqualToAnchor(profileImageView.centerYAnchor).active = true
        
        
        //        timeLabel.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        //        timeLabel.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 8).active = true
        //        timeLabel.widthAnchor.constraintEqualToConstant(100).active = true
        //        timeLabel.heightAnchor.constraintEqualToConstant(50).active = true
        
        likeButton.rightAnchor.constraintEqualToAnchor(likesLabel.leftAnchor, constant: -8).active = true
        likeButton.centerYAnchor.constraintEqualToAnchor(profileImageView.centerYAnchor).active = true
        likeButton.widthAnchor.constraintEqualToConstant(40).active = true
        likeButton.heightAnchor.constraintEqualToConstant(40).active = true
        
        likesLabel.rightAnchor.constraintEqualToAnchor(cellContainerView.rightAnchor, constant: -16).active = true
        likesLabel.topAnchor.constraintEqualToAnchor(likeButton.centerYAnchor).active = true
        
        
        likeCount.centerXAnchor.constraintEqualToAnchor(likesLabel.centerXAnchor).active = true
        likeCount.bottomAnchor.constraintEqualToAnchor(likeButton.centerYAnchor).active = true
    }
    
    func setupDescriptionTextShowcaseImage(){
        descriptionText.centerXAnchor.constraintEqualToAnchor(cellContainerView.centerXAnchor).active = true
        descriptionText.topAnchor.constraintEqualToAnchor(profileImageView.bottomAnchor, constant: 8).active = true
        descriptionText.widthAnchor.constraintEqualToAnchor(cellContainerView.widthAnchor, constant: -16).active = true
        descriptionText.heightAnchor.constraintGreaterThanOrEqualToConstant(40).active = true
        
        showcaseImageView.centerXAnchor.constraintEqualToAnchor(cellContainerView.centerXAnchor).active = true
        showcaseImageView.topAnchor.constraintEqualToAnchor(descriptionText.bottomAnchor, constant: 8).active = true
        showcaseImageView.widthAnchor.constraintEqualToAnchor(cellContainerView.widthAnchor, constant: -16).active = true
        showcaseImageView.bottomAnchor.constraintEqualToAnchor(cellContainerView.bottomAnchor, constant: -28).active = true
        
        separatorLineView.leftAnchor.constraintEqualToAnchor(cellContainerView.leftAnchor).active = true
        separatorLineView.bottomAnchor.constraintEqualToAnchor(cellContainerView.bottomAnchor, constant: -24).active = true
        separatorLineView.widthAnchor.constraintEqualToAnchor(cellContainerView.widthAnchor).active = true
        separatorLineView.heightAnchor.constraintEqualToConstant(1).active = true

        
        contentView.addSubview(cellContainerView)
        
        cellContainerView.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor).active = true
        cellContainerView.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor).active = true
        cellContainerView.widthAnchor.constraintEqualToAnchor(contentView.widthAnchor, constant: -16).active = true
        cellContainerView.heightAnchor.constraintEqualToAnchor(contentView.heightAnchor, constant: -16).active = true

    }
    
    func handleLikeButtonTapped(sender: UIButton){
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let _ = snapshot.value as? NSNull{
                //This means that we have not liked this specific post
                let image = UIImage(named: "iLike")
                self.likeButton.setImage(image, forState: .Normal)
                self.userPost!.adjustLikes(true)
                self.likeRef.setValue(true)
                let likeBtn = sender
                    likeBtn.tag = 1
                self.postViewController!.adjustLikesInArrayDisplay(likeBtn)
                //self.postViewController!.handleReloadPosts()
            }else{
                let image = UIImage(named: "Like")
                self.likeButton.setImage(image, forState: .Normal)
                self.userPost!.adjustLikes(false)
                self.likeRef.removeValue()
                let likeBtn = sender
                likeBtn.tag = 0
                self.postViewController!.adjustLikesInArrayDisplay(likeBtn)
                //self.postViewController!.handleReloadPosts()
            }
        })

        
    }
    
    func likeTapped(tapGesture: UITapGestureRecognizer){
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let _ = snapshot.value as? NSNull{
                //This means that we have not liked this specific post
                let image = UIImage(named: "iLike")
                self.likeButton.setImage(image, forState: .Normal)
                //self.likeImageView.image = UIImage(named: "iLike")
                self.userPost!.adjustLikes(true)
                self.likeRef.setValue(true)
                self.postViewController!.handleReloadPosts()
            }else{
                let image = UIImage(named: "Like")
                self.likeButton.setImage(image, forState: .Normal)
                //self.likeImageView.image = UIImage(named: "Like")
                self.userPost!.adjustLikes(false)
                self.likeRef.removeValue()
                self.postViewController!.handleReloadPosts()
            }
        })
    }
    
    func handleZoom(tapGesture: UITapGestureRecognizer){
        
        if let imageView = tapGesture.view as? UIImageView{
            postViewController?.performZoomInForStartingImageView(imageView)
        }
        
    }
    
    func handlePostVideoPlay(sender: UIButton) {
        postViewController?.handlePlayPostVideo(sender)
    }
    
    func setupVideoPostCell(cell: testPostCell){
        
        let playButton = PlayButton()
        
        playButton.addTarget(self, action: #selector(handlePostVideoPlay), forControlEvents: .TouchUpInside)
        
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
    
}

//extension testPostCell: UITextViewDelegate{
//    func textViewDidChange(textView: UITextView) {
//        let fixedWidth = textView.frame.size.width
//        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
//        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
//        var newFrame = textView.frame
//        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
//        textView.frame = newFrame;
//    }
//}
