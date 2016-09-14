//
//  NewMessagesController.swift
//  ChatHook
//
//  Created by Kevin Farm on 8/22/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class NewMessagesController: UITableViewController {

    let cellID = "cellID"
    var usersArray = [User]()
    let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
    var currentUser: User?
    var userLat: Double?
    var userLong: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(handleCancel))
        fetchCurrentUserLocation()
        observeUsersOnline()
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: "cellID")
        
    }
    
    func fetchCurrentUserLocation(){
        let currentUserLocationRef = DataService.ds.REF_USERSONLINE.child(uid)
        currentUserLocationRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dictionary = snapshot.value as? [String : AnyObject]{
                    self.currentUser?.location = CLLocation(latitude: dictionary["UserLatitude"] as! Double, longitude: (dictionary["UserLongitude"] as! Double))
                    }
                },
            withCancelBlock: nil)
    }
    
    func observeUsersOnline(){
        usersArray = []
        let ref = DataService.ds.REF_USERSONLINE
            ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
                let userID = snapshot.key
                let userRef = DataService.ds.REF_USERS.child(userID)
                
                let latLongRef = ref.child(userID)
                latLongRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject]{
                            self.userLat = dictionary["UserLatitude"] as? Double
                            self.userLong = dictionary["UserLongitude"] as? Double
                        }
                    }, withCancelBlock: nil)
                
                
                userRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject]{
                            let userPostKey = snapshot.key
                            let user = User(postKey: userPostKey, dictionary: dictionary)
                                user.location = CLLocation(latitude: self.userLat!, longitude: self.userLong!)
                            if user.postKey != self.currentUser?.postKey{
                                self.usersArray.append(user)
                            }
                            dispatch_async(dispatch_get_main_queue(), {
                                self.tableView.reloadData()
                            })
                        }
                    }, withCancelBlock: nil)
                }, withCancelBlock: nil)
    }
    
    func handleCancel(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersArray.count
    }
    
    func calculateDistance(otherLocation: CLLocation) -> String {
        let distanceInMeters = currentUser?.location!.distanceFromLocation(otherLocation)
        let distanceInMiles = (distanceInMeters! / 1000) * 0.62137
        let stringDistance = String(format: "%.2f", distanceInMiles)
        let passedString = "\(stringDistance) miles away"
        return passedString
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! UserCell
        let user = usersArray[indexPath.row]
            cell.textLabel?.text = user.userName
            cell.detailTextLabel?.text = calculateDistance(user.location!)
            cell.accessoryType = UITableViewCellAccessoryType.DetailButton
            
            if let profileImageUrl = user.profileImageUrl{
                cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        return cell
    }
    
    var messagesController: MessagesController?
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dismissViewControllerAnimated(true){
            print("Dismiss completed")
            let user = self.usersArray[indexPath.row]
            self.messagesController?.showChatControllerForUser(user)
        }
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let user = usersArray[indexPath.row]
        
        let ref = DataService.ds.REF_USERS.child(user.postKey)
        
        ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
            let user = User(postKey: snapshot.key, dictionary: dictionary)
            self.showProfileControllerForUser(user)
            }, withCancelBlock: nil)
        
    }
    
    func showProfileControllerForUser(user: User){
        let profileController = ProfileViewController()
        profileController.selectedUser = user
        
        navigationController?.pushViewController(profileController, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }}
