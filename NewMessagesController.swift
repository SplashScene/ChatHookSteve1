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
    var groupedUsersArray = [GroupedUsers]()
    var usersArray1 = [User]()
    var usersArray2 = [User]()
    var usersArray3 = [User]()
    let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
    var userLat: Double?
    var userLong: Double?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(handleCancel))
        
        observeUsersOnline()
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: "cellID")
        
    }
    

    func observeUsersOnline(){
            
            groupedUsersArray = []

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
                                       
                                        if user.postKey != CurrentUser._postKey{
                                            let distanceFromMe = self.calculateDistance(user.location)
                                            let distanceDouble = distanceFromMe["DistanceDouble"] as! Double
                                            
                                            switch distanceDouble{
                                                case 0...1.099:
                                                    self.usersArray1.append(user)
                                                    self.groupedUsersArray.append(GroupedUsers(sectionName: "Within a mile", sectionUsers: self.usersArray1))
                                                case 1.1...5.0:
                                                    self.usersArray2.append(user)
                                                    self.groupedUsersArray.append(GroupedUsers(sectionName: "Within 5 miles", sectionUsers: self.usersArray2))
                                                default:
                                                    self.usersArray3.append(user)
                                                    self.groupedUsersArray.append(GroupedUsers(sectionName: "Over 5 miles", sectionUsers: self.usersArray3))
                                            }
                                        }
                                        
                                        dispatch_async(dispatch_get_main_queue(), {
                                            self.tableView.reloadData()
                                        })
                                    }
                            }, withCancelBlock: nil)
                        }
                    }, withCancelBlock: nil)
                }, withCancelBlock: nil)
  
    }
    
    func handleCancel(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return groupedUsersArray.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedUsersArray[section].sectionUsers.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! UserCell
        let user = groupedUsersArray[indexPath.section].sectionUsers[indexPath.row]
        let distanceDictionary = calculateDistance(user.location!)
        let distanceString = distanceDictionary["DistanceString"] as! String
    
        cell.textLabel?.text = user.userName
        cell.detailTextLabel?.text = distanceString
        cell.accessoryType = UITableViewCellAccessoryType.DetailButton
        
        if let profileImageUrl = user.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
    return cell
}
    
    var messagesController: MessagesController?
    
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
    
    func calculateDistance(otherLocation: CLLocation) -> [String: AnyObject] {
        var distanceDictionary:[String: AnyObject]
        let myLocation = CurrentUser._location
        
        let distanceInMeters = myLocation.distanceFromLocation(otherLocation)
        let distanceInMiles = (distanceInMeters / 1000) * 0.62137
        
        let stringDistance = String(format: "%.2f", distanceInMiles)
        let passedString = "\(stringDistance) miles away"

        distanceDictionary = ["DistanceDouble": distanceInMiles, "DistanceString": passedString]
        
        return distanceDictionary

    }
    
    func showProfileControllerForUser(user: User){
        let profileController = ProfileViewController()
        profileController.selectedUser = user
        
        let navController = UINavigationController(rootViewController: profileController)
        presentViewController(navController, animated: true, completion: nil)

    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }}
