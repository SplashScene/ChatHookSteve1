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
    var currentUserLocation:CLLocation?
    let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(handleCancel))
        fetchCurrentUser()
        fetchUser()
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: "cellID")
        
    }
    
    func fetchCurrentUser(){
        let currentUser = DataService.ds.REF_USER_CURRENT
        currentUser.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject]{
                self.currentUserLocation = CLLocation(latitude: dictionary["UserLatitude"] as! Double, longitude: (dictionary["UserLongitude"] as! Double))
            }
            },
            withCancelBlock: nil)
    }
    
    func fetchUser(){
        FIRDatabase.database().reference().child("users").observeEventType(.ChildAdded, withBlock: {
            (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let userPostKey = snapshot.key
                    let user = User(postKey: userPostKey, dictionary: dictionary)
                    if user.postKey != self.uid {
                        self.usersArray.append(user)
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            },
                withCancelBlock: nil)
        
        
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
        let distanceInMeters = currentUserLocation!.distanceFromLocation(otherLocation)
        let distanceInMiles = (distanceInMeters / 1000) * 0.62137
        let stringDistance = String(format: "%.2f", distanceInMiles)
        let passedString = "\(stringDistance) miles away"
        return passedString
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! UserCell
        let user = usersArray[indexPath.row]
            cell.textLabel?.text = user.userName
            cell.detailTextLabel?.text = calculateDistance(user.location)
            
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }}
