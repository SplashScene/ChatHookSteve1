//
//  ChatPostCell.swift
//  driveby_Showcase
//
//  Created by Kevin Farm on 4/13/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class ChatPostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    
    var post: ChatPost!
    var request: Request?
    var likeRef: FIRDatabaseReference!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChatPostCell.likeTapped(_:)))
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.userInteractionEnabled = true
        
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImg.layer.cornerRadius = 5.0
        showcaseImg.clipsToBounds = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(post: ChatPost, img: UIImage?){
        self.post = post
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        self.userName.text = post.userName
        likeRef = DataService.ds.REF_USER_CURRENT.child("Likes").child(post.postKey)
        
        if post.imageURL != nil{
            if img != nil {
                self.showcaseImg.image = img
                print("I GOT AN IMAGE PASSED TO ME!!!!")
            }else{
                print("I had to download picture (none passed) for cell: \(post.postDescription)")
                request = Alamofire.request(.GET, post.imageURL!).validate(contentType:["image/*"]).response(completionHandler: { request, response, data, err in
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.showcaseImg.image = img
                        PostsVC.imageCache.setObject(img, forKey: self.post.imageURL!)
                    }// end if err
                })//end completion handler
            }
        }else{
            self.showcaseImg.image = UIImage(named: "camera")
            //self.showcaseImg.hidden = true
        }//end else
        
        
        request = Alamofire.request(.GET, post.profilePic).validate(contentType:["image/*"]).response(completionHandler: { request, response, data, err in
            if err == nil {
                let img = UIImage(data: data!)!
                self.profileImg.image = img
                
            }// end if err
        })//end completion handler
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let _ = snapshot.value as? NSNull{
                //This means that we have not liked this specific post
                self.likeImage.image = UIImage(named: "heart-empty")
            }else{
                self.likeImage.image = UIImage(named: "heart-full")
            }
        })
    }//end configureCell
    
 
    func likeTapped(sender: UITapGestureRecognizer){
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let _ = snapshot.value as? NSNull{
                //This means that we have not liked this specific post
                self.likeImage.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
            }else{
                self.likeImage.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
        })
        
    }
    
}//end class PostCell

