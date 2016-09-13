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
    
    var userPost: UserPost?{
        didSet{
                let ref = DataService.ds.REF_POSTS.child(userPost!.postKey!)
                    ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject]{
                        
                        self.userNameLabel.text = dictionary["authorName"] as? String
                        self.descriptionText.text = dictionary["postText"] as? String
                        self.likeCount.text = String(dictionary["likes"]!)
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
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
//        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
//    }
    
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
    
    lazy var likeImageView: UIImageView = {
        let imageView = UIImageView()
            imageView.image = UIImage(named: "Like")
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .ScaleAspectFill
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleLike)))
            imageView.userInteractionEnabled = true
        
        return imageView
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
            label.text = "HH:MM:SS"
            label.font = UIFont.systemFontOfSize(12)
            label.textColor = UIColor.lightGrayColor()
            label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let likeCount: UILabel = {
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
            label.text = "Likes"
            label.font = UIFont(name: "Avenir Medium", size:  12.0)
            label.textColor = UIColor.darkGrayColor()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.sizeToFit()
        return label
    }()
    
    let descriptionText: UITextField = {
        let descripText = UITextField()
            descripText.translatesAutoresizingMaskIntoConstraints = false
            descripText.text = "This is sample description text for the post"
            descripText.font = UIFont(name: "Avenir Medium", size:  14.0)
            descripText.textColor = UIColor.darkGrayColor()
            descripText.userInteractionEnabled = false
        return descripText
    }()
    
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


    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(userNameLabel)
        addSubview(likeImageView)
        addSubview(likeCount)
        addSubview(likesLabel)
        addSubview(descriptionText)
        addSubview(showcaseImageView)
        
        //need x, y, width, height anchors
        profileImageView.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 8).active = true
        profileImageView.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 8).active = true
        profileImageView.widthAnchor.constraintEqualToConstant(48).active = true
        profileImageView.heightAnchor.constraintEqualToConstant(48).active = true
        
        userNameLabel.leftAnchor.constraintEqualToAnchor(profileImageView.rightAnchor, constant: 8).active = true
        userNameLabel.centerYAnchor.constraintEqualToAnchor(profileImageView.centerYAnchor).active = true
        
        
//        timeLabel.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
//        timeLabel.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 8).active = true
//        timeLabel.widthAnchor.constraintEqualToConstant(100).active = true
//        timeLabel.heightAnchor.constraintEqualToConstant(50).active = true
        
        likeImageView.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -48).active = true
        likeImageView.centerYAnchor.constraintEqualToAnchor(profileImageView.centerYAnchor).active = true
        likeImageView.widthAnchor.constraintEqualToConstant(40).active = true
        likeImageView.heightAnchor.constraintEqualToConstant(40).active = true
        
        likesLabel.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -8).active = true
        likesLabel.topAnchor.constraintEqualToAnchor(likeImageView.centerYAnchor).active = true

        
        likeCount.centerXAnchor.constraintEqualToAnchor(likesLabel.centerXAnchor).active = true
        likeCount.bottomAnchor.constraintEqualToAnchor(likeImageView.centerYAnchor).active = true
        
        descriptionText.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
        descriptionText.topAnchor.constraintEqualToAnchor(profileImageView.bottomAnchor, constant: 8).active = true
        descriptionText.widthAnchor.constraintEqualToAnchor(self.widthAnchor, constant: -16).active = true
        descriptionText.heightAnchor.constraintGreaterThanOrEqualToConstant(40).active = true
        
        showcaseImageView.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
        showcaseImageView.topAnchor.constraintEqualToAnchor(descriptionText.bottomAnchor, constant: 8).active = true
        showcaseImageView.widthAnchor.constraintEqualToAnchor(self.widthAnchor, constant: -16).active = true
        showcaseImageView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: -8).active = true


    }

    func toggleLike(){
        if postLiked {
            likeImageView.image = UIImage(named: "iLike")
        }else{
            likeImageView.image = UIImage(named: "Like")
        }
        
        postLiked = !postLiked
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
