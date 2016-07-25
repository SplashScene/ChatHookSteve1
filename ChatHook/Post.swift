//
//  Post.swift
//  ChatHook
//
//  Created by Kevin Farm on 5/23/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

class Post{
    private var _userName: String!
    private var _profilePic: String!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    private var _location: CLLocation?
    
    var userName: String { return _userName }
    var profilePic: String { return _profilePic }
    var postKey: String { return _postKey }
    var location: CLLocation { return _location! }
    
    init(postKey: String, dictionary: Dictionary<String, String>){
        self._postKey = postKey
        
        if let profileURL = dictionary["ProfileImage"]{
            self._profilePic = profileURL
        }else{
            self._profilePic = "http://imageshack.com/a/img922/8259/MrQ96I.png"
        }
        
        if let profileName = dictionary["UserName"]{
            //print("The name of the profile name is: \(profileName)")
            self._userName = profileName
        }else{
            self._userName = "AnonymousPoster"
        }
        
        if let lat = dictionary["UserLatitude"], long = dictionary["UserLongitude"]{
            self._location = CLLocation(latitude: Double(lat)!, longitude: Double(long)!)
        }
        
        self._postRef = DataService.ds.REF_USERS.child(self._postKey)
        
        
    }
    
}

