//
//  PostCell.swift
//  ChatHook
//
//  Created by Kevin Farm on 5/23/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    var user: User!
    var request: Request?
    var likeRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    func configureCell(post: User, img: UIImage?, distance: String){
        if post.profilePic != nil{
            if img != nil {
                self.profileImg.image = img
                print("I GOT AN IMAGE PASSED TO ME!!!!")
            }else{
                print("I had to download the image again")
                request = Alamofire.request(.GET, post.profilePic!).validate(contentType:["image/*"]).response(completionHandler: { request, response, data, err in
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.profileImg.image = img
                        FeedVC.imageCache.setObject(img, forKey: post.profilePic!)
                        
                    }// end if err
                })//end completion handler
                self.distanceLabel.text = distance
            }
        }else{
            self.profileImg.image = UIImage(named: "profileToon.jpg")
            //self.showcaseImg.hidden = true
        }//end else
    }
//        self.user = post
//            self.userName.text = post.userName
//        
//            request = Alamofire.request(.GET, post.profilePic).validate(contentType:["image/*"]).response(completionHandler: { request, response, data, err in
//            if err == nil {
//                let img = UIImage(data: data!)!
//                self.profileImg.image = img
//
//            }// end if err
//        })//end completion handler
        

}//end class PostCell
