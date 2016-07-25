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
    
    var user: User!
    var request: Request?
    var likeRef: FIRDatabaseReference!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    func configureCell(post: User){
        
        self.user = post
            self.userName.text = post.userName
        
            request = Alamofire.request(.GET, post.profilePic).validate(contentType:["image/*"]).response(completionHandler: { request, response, data, err in
            if err == nil {
                let img = UIImage(data: data!)!
                self.profileImg.image = img
                
            }// end if err
        })//end completion handler
        
    }//end configureCell

}//end class PostCell
