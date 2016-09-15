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
    var userLat: Double?
    var userLong: Double?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(handleCancel))
        
        observeUsersOnline()
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: "cellID")
        
    }
    

    
    func observeUsersOnline(){
        
        
        
            let searchLat = Int(CurrentUser._location.coordinate.latitude)
            let searchLong = Int(CurrentUser._location.coordinate.longitude)
            usersArray = []
            let ref = DataService.ds.REF_USERSONLINE.child("\(searchLat)").child("\(searchLong)")
            
            ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
                let userID = snapshot.key
                var userLocation: CLLocation?

                let latLongRef = ref.child(userID)
                    print("The LATLONGREF is: \(latLongRef)")
                    latLongRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            if let dictionary = snapshot.value as? [String: AnyObject]{
                                userLocation = CLLocation(latitude: dictionary["userLatitude"] as! Double, longitude: dictionary["userLongitude"] as! Double)
//                                self.userLat = dictionary["userLatitude"] as? Double
//                                self.userLong = dictionary["userLongitude"] as? Double
                                print("The Latitude is: \(userLocation?.coordinate.latitude) and the Longytude is: \(userLocation?.coordinate.longitude)")
                                let userRef = DataService.ds.REF_USERS.child(userID)
                                userRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                                    if let dictionary = snapshot.value as? [String: AnyObject]{
                                        let userPostKey = snapshot.key
                                        let user = User(postKey: userPostKey, dictionary: dictionary)
                                        print("The USER \(user.userName) latii is: \(userLocation?.coordinate.latitude) and the longii is: \(userLocation?.coordinate.longitude)")
                                        user.location = userLocation
                                        //                                user.location = CLLocation(latitude: self.userLat!, longitude: self.userLong!)
                                        if user.postKey != CurrentUser._postKey{
                                            
                                            self.usersArray.append(user)
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
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersArray.count
    }
    
    func calculateDistance(otherLocation: CLLocation) -> String {
        let myLocation = CurrentUser._location
        
            let distanceInMeters = myLocation.distanceFromLocation(otherLocation)
            let distanceInMiles = (distanceInMeters / 1000) * 0.62137
            print("The distance in meters is: \(distanceInMeters)")
            let stringDistance = String(format: "%.2f", distanceInMiles)
            let passedString = "\(stringDistance) miles away"
            return passedString

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! UserCell
        let user = usersArray[indexPath.row]
            print("The user \(user.userName) latitude is: \(user.location?.coordinate.latitude) and the longitude is: \(user.location?.coordinate.longitude)")
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
            
            let user = self.usersArray[indexPath.row]
            self.messagesController?.showChatControllerForUser(user)
        }
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        
            let user = self.usersArray[indexPath.row]
            self.showProfileControllerForUser(user)
        
    }
    
    func showProfileControllerForUser(user: User){
        let profileController = ProfileViewController()
        profileController.selectedUser = user
        
        navigationController?.pushViewController(profileController, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }}
