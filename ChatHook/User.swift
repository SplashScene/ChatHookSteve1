//
//  User.swift
//  ChatHook
//
//  Created by Kevin Farm on 7/24/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

class User{
    private var _userName: String!
    private var _profileImageUrl: String?
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    private var _location: CLLocation?
    private var _online: Bool!
    private var _email: String!
    
    var userName: String { return _userName }
    var profileImageUrl: String? { return _profileImageUrl }
    var postKey: String { return _postKey }
    var location: CLLocation { return _location! }
    var online: Bool { return _online }
    var email: String { return _email }
    
    init(postKey: String, dictionary: Dictionary<String, AnyObject>){
        self._postKey = postKey
        
        if let profileURL = dictionary["ProfileImage"] as? String{
            self._profileImageUrl = profileURL
        }else{
            self._profileImageUrl = "http://imageshack.com/a/img922/8259/MrQ96I.png"
        }
        
        if let profileName = dictionary["UserName"] as? String{
            self._userName = profileName
        }else{
            self._userName = "AnonymousPoster"
        }
        
        if let lat = dictionary["UserLatitude"], long = dictionary["UserLongitude"]{
            self._location = CLLocation(latitude: (lat as? Double)!, longitude: (long as? Double)!)
        }
        
        if let userOnline = dictionary["Online"] as? Bool{
            self._online = userOnline
        }
        
        if let userEmail = dictionary["email"] as? String{
            self._email = userEmail
        }
        
        self._postRef = DataService.ds.REF_USERS.child(self._postKey)
        //observeMessages()
    }
    
    func observeMessages(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        let userMessagesRef = DataService.ds.REF_USERMESSAGES.child(uid)
        
        userMessagesRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let messageID = snapshot.key
            let messagesRef = DataService.ds.REF_MESSAGES.child(messageID)
            messagesRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                
                let message = Message()
                message.setValuesForKeysWithDictionary(dictionary)
                print(message.text)
                }, withCancelBlock: nil)
            }, withCancelBlock: nil)
    }
    
}
