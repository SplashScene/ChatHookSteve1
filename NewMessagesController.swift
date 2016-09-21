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

    var messagesController: MessagesController?
    let cellID = "cellID"
    var groupedUsersArray = [GroupedUsers]()
    var blockedUsersArray = [String]()
    var usersArray1 = [User]()
    var usersArray2 = [User]()
    var usersArray3 = [User]()
    //let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
    var userLat: Double?
    var userLong: Double?
    var timer: NSTimer?
    
    
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(handleCancel))
        
        navigationItem.title = "People Near You"
        observeUsersOnline()
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: "cellID")
        blockedUsersArray = []
        print("My post key is: \(CurrentUser._postKey)")
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    //MARK: - Observe Methods
    func observeUsersOnline(){
        groupedUsersArray = []
        print("The count of the blocked users array is: \(CurrentUser._blockedUsersArray?.count)")

        let searchLat = Int(CurrentUser._location.coordinate.latitude)
        let searchLong = Int(CurrentUser._location.coordinate.longitude)

        let ref = DataService.ds.REF_USERSONLINE.child("\(searchLat)").child("\(searchLong)")
        
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let userID = snapshot.key
            var userLocation: CLLocation?
            
            let latLongRef = ref.child(userID)
            
                latLongRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject]{
                        
                        userLocation = CLLocation(latitude: dictionary["userLatitude"] as! Double,
                                                  longitude: dictionary["userLongitude"] as! Double)
                        
                        let userRef = DataService.ds.REF_USERS.child(userID)
                            userRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                                if let dictionary = snapshot.value as? [String: AnyObject]{
                                    let userPostKey = snapshot.key
                                    let user = User(postKey: userPostKey, dictionary: dictionary)
                                        user.location = userLocation
                                    if let isBlockedUser = CurrentUser._blockedUsersArray?.contains(user.postKey){
                                        user.isBlocked = isBlockedUser
                                        print("User is blocked is: \(isBlockedUser)")
                                        if user.isBlocked == true{
                                            print("I cock blocked: \(user.userName)")
                                        }
                                    }
                                    
                                    userRef.child("blocked_users").child(CurrentUser._postKey).observeEventType(.Value, withBlock: { (snapshot) in
                                        if let _ = snapshot.value as? NSNull{
                                            if user.postKey != CurrentUser._postKey{
                                                
                                                let distanceFromMe = self.messagesController!.calculateDistance(user.location)
                                                let distanceDouble = distanceFromMe["DistanceDouble"] as! Double
                                                user.distance = distanceDouble
                                                
                                                self.loadDistanceArrays(user.distance!, user: user)
                                                
                                                self.timer?.invalidate()
                                                self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.loadSections), userInfo: nil, repeats: false)
                                            }

                                        }else{
                                            print("\(user.userName) cock blocked me")
                                        }
                                    }, withCancelBlock: nil)
                                }
                                
                        }, withCancelBlock: nil)
                    }
                }, withCancelBlock: nil)
            
            }, withCancelBlock: nil)
    }
    
    //MARK: - Load Handlers
    
    func loadDistanceArrays(distanceDouble: Double, user: User){
        switch distanceDouble{
            case 0...1.099:
                self.usersArray1.append(user)
                self.usersArray1.sortInPlace({ (user1, user2) -> Bool in
                    return user1.distance < user2.distance
                })
            case 1.1...5.0:
                self.usersArray2.append(user)
                self.usersArray2.sortInPlace({ (user1, user2) -> Bool in
                    return user1.distance < user2.distance
                })
            default:
                self.usersArray3.append(user)
                self.usersArray3.sortInPlace({ (user1, user2) -> Bool in
                    return user1.distance < user2.distance
                })
            }
    }
    
    func loadSections(){
        if usersArray1.count > 0 {
            self.groupedUsersArray.append(GroupedUsers(sectionName: "Within a mile", sectionUsers: self.usersArray1))
        }
        if usersArray2.count > 0 {
            self.groupedUsersArray.append(GroupedUsers(sectionName: "Within 5 miles", sectionUsers: self.usersArray2))
        }
        if usersArray3.count > 0 {
            self.groupedUsersArray.append(GroupedUsers(sectionName: "Over 5 miles", sectionUsers: self.usersArray3))
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })

    }
    
    func handleCancel(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showProfileControllerForUser(user: User){
        let profileController = ProfileViewController()
        profileController.selectedUser = user
        
        let navController = UINavigationController(rootViewController: profileController)
        presentViewController(navController, animated: true, completion: nil)
    }
    
    //MARK: - TableView Methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return groupedUsersArray.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedUsersArray[section].sectionUsers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! UserCell
        let user = groupedUsersArray[indexPath.section].sectionUsers[indexPath.row]
        
        if let stringDistance = user.distance {
            let unwrappedString = String(format: "%.2f", (stringDistance))
            let distanceString = "\(unwrappedString) miles away"
            cell.detailTextLabel?.text = distanceString
        }
        
        if user.isBlocked == true{
            cell.backgroundColor = UIColor(r: 255, g: 99, b: 71)
        }else{
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        cell.textLabel?.text = user.userName
        cell.accessoryType = UITableViewCellAccessoryType.DetailButton
        
        if let profileImageUrl = user.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dismissViewControllerAnimated(true){
            let user = self.groupedUsersArray[indexPath.section].sectionUsers[indexPath.row]
            self.messagesController?.showChatControllerForUser(user)
        }
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
            let user = self.groupedUsersArray[indexPath.section].sectionUsers[indexPath.row]
            self.showProfileControllerForUser(user)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groupedUsersArray[section].sectionName
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }
}



