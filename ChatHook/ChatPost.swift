//
//  ChatPost.swift
//  driveby_Showcase
//
//  Created by Kevin Farm on 4/14/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import Foundation
import Firebase

class ChatPost{
    private var _postDescription: String!
    private var _imageURL: String?
    private var _likes: Int!
    private var _userName: String!
    private var _profilePic: String!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    
    var postDescription: String { return _postDescription }
    var imageURL: String? { return _imageURL }
    var likes: Int { return _likes }
    var userName: String { return _userName }
    var profilePic: String { return _profilePic }
    var postKey: String { return _postKey }
    
    init(description: String, imageURL: String?, userName: String){
        self._postDescription = description
        self._imageURL = imageURL
        self._userName = userName
    }
    
    init(postKey: String, dictionary: Dictionary<String, AnyObject>){
        self._postKey = postKey
        
        if let likes = dictionary["Likes"] as? Int{
            self._likes = likes
        }
        
        if let imgURL = dictionary["PostURL"] as? String{
            self._imageURL = imgURL
        }
        
        if let desc = dictionary["Description"] as? String{
            self._postDescription = desc
        }
        
        if let profileURL = dictionary["AuthorPic"] as? String{
            self._profilePic = profileURL
        }else{
            self._profilePic = "http://imageshack.com/a/img922/8259/MrQ96I.png"
        }
        if let profileName = dictionary["Author"] as? String{
            self._userName = profileName
        }else{
            self._userName = "AnonymousPoster"
        }
        
        self._postRef = DataService.ds.REF_POSTS.child(self._postKey)
        
        
    }
    
    func adjustLikes(addLike: Bool){
        _likes = addLike ? _likes + 1 :  _likes - 1
        _postRef.child("Likes").setValue(_likes)
    }
}

