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
    
    var post: Post!
    var request: Request?
    var likeRef: FIRDatabaseReference!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    func configureCell(post: Post){
        
        self.post = post
        print("The self post userName is: \(post.userName)")
        print("The pic image is: \(post.profilePic)")

        print("Inside Configure Cell the user name is \(post.userName)")
        
            self.userName.text = post.userName
        
            request = Alamofire.request(.GET, post.profilePic).validate(contentType:["image/*"]).response(completionHandler: { request, response, data, err in
            if err == nil {
                let img = UIImage(data: data!)!
                self.profileImg.image = img
                
            }// end if err
        })//end completion handler
        
    }//end configureCell

}//end class PostCell
