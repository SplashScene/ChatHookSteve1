//
//  DataService.swift
//  driveby_Showcase
//
//  Created by Kevin Farm on 4/12/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = FIRDatabase.database().reference()

class DataService {
    static let ds = DataService()
    
    private var _REF_BASE = URL_BASE
    private var _REF_POSTS = URL_BASE.child("posts")
    private var _REF_USERS = URL_BASE.child("users")
    private var _REF_MESSAGES = URL_BASE.child("messages")
    private var _REF_CHATROOMS = URL_BASE.child("publicchatrooms")
    
    
    var REF_BASE: FIRDatabaseReference{ return _REF_BASE }
    var REF_POSTS: FIRDatabaseReference{ return _REF_POSTS }
    var REF_USERS: FIRDatabaseReference{ return _REF_USERS }
    var REF_MESSAGES: FIRDatabaseReference{ return _REF_MESSAGES }
    var REF_CHATROOMS: FIRDatabaseReference{ return _REF_CHATROOMS }
    
    var REF_USER_CURRENT: FIRDatabaseReference{
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = URL_BASE.child("users").child(uid)
        return user
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>){
        REF_USERS.child(uid).setValue(user)
    }
    
}