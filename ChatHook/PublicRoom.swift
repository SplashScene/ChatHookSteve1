//
//  Post.swift
//  ChatHook
//
//  Created by Kevin Farm on 5/23/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import Foundation
import Firebase

class PublicRoom{
  
    private var _userName: String!
    private var _profilePic: String!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    private var _roomName: String!
    
    var userName: String { return _userName }
    var profilePic: String { return _profilePic }
    var postKey: String { return _postKey }
    var roomName: String { return _roomName }
    
    init(description: String, imageURL: String?, userName: String){
        //        self._postDescription = description
        //        self._imageURL = imageURL
        self._userName = userName
    }
    
    init(postKey: String, dictionary: Dictionary<String, AnyObject>){
        self._postKey = postKey
        
        if let profileURL = dictionary["AuthorPic"] as? String{
            self._profilePic = profileURL
        }else{
            self._profilePic = "http://imageshack.com/a/img922/8259/MrQ96I.png"
        }
        if let profileName = dictionary["Author"] as? String{
            print("The name of the profile name is: \(profileName)")
            self._userName = profileName
        }else{
            self._userName = "AnonymousPoster"
        }
        if let profileRoomName = dictionary["RoomName"] as? String{
            self._roomName = profileRoomName
        }else{
            self._roomName = "Kendall's House of Horrors"
        }
        
        self._postRef = DataService.ds.REF_USERS.child(self._postKey)   
    }
    
   
}

