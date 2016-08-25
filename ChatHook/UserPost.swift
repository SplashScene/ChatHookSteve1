//
//  UserPost.swift
//  ChatHook
//
//  Created by Kevin Farm on 8/24/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit

class UserPost: NSObject {
    var postKey: String?
    var fromID: String?
    var postText: String?
    var timestamp: NSNumber?
    var toRoom: String?
    var likes: NSNumber?
    var showcaseImg: String?
    var authorPic: String?
    var authorName: String?
    
    init(key: String){
        postKey = key
    }
}
