//
//  FeedVC.swift
//  ChatHook
//
//  Created by Kevin Farm on 5/23/16.
//  Copyright © 2016 splashscene. All rights reserved.
//



import UIKit
import Firebase
import Alamofire
import CoreLocation

class FeedVC: UIViewController{
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var usersArray:[User] = []
    static var imageCache = NSCache()
    
    var postedImage: UIImage?
    var currentUserName: String!
    var currentProfilePicURL: String!
    var currentUserUID: String!
    var currentUserLocation: CLLocation!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        progressView.hidden = true
        activityIndicatorView.hidden = true
        
        
        tableView.estimatedRowHeight = 65
        let currentUser = DataService.ds.REF_USER_CURRENT
        //let refUsers = DataService.ds.REF_USERS.queryOrderedByChild("Online").queryEqualToValue("true")
        
        currentUser.observeEventType(.Value, withBlock: {
            snapshot in
            self.currentUserUID = snapshot.key
            if let myUserName = snapshot.value!.objectForKey("UserName"),
               let myProfilePic = snapshot.value!.objectForKey("ProfileImage"),
               let userLat = snapshot.value!.objectForKey("UserLatitude"),
               let userLong = snapshot.value?.objectForKey("UserLongitude"){
                    self.currentUserName = myUserName as! String
                    self.currentProfilePicURL = myProfilePic  as! String
                    self.currentUserLocation = CLLocation(latitude: userLat as! Double, longitude: userLong as! Double)
            }
        })
        /*
         let typingIndicatorRef = DataService.ds.REF_BASE.child("typingIndicator")
         userIsTypingRef = typingIndicatorRef.child(senderId)
         userIsTypingRef.onDisconnectRemoveValue()
         
         usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqualToValue(true)
         
         usersTypingQuery.observeEventType(.Value) { (data: FIRDataSnapshot!) in

 
        let userRef = DataService.ds.REF_USERS
        let userOnlineRef = userRef.child("Online")
        let usersOnline = userOnlineRef.queryOrderedByValue().queryEqualToValue(true)
        
        usersOnline.observeEventType(.Value, withBlock: {
            snapshot in
            
            self.usersArray = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    if let postDict = snap.value as? Dictionary<String, AnyObject>{
                        let key = snap.key
                        let user = User(postKey: key, dictionary: postDict)
                        self.usersArray.append(user)
                    }
                }
            }
            self.tableView.reloadData()
        })
 */

        DataService.ds.REF_USERS.queryOrderedByChild("Online").observeEventType(.Value, withBlock: {
            snapshot in
            
            self.usersArray = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    if let postDict = snap.value as? Dictionary<String, AnyObject>{
                        let online = postDict["Online"] as! Bool
                            if online{
                                let key = snap.key
                                let user = User(postKey: key, dictionary: postDict)
                                self.usersArray.append(user)
                            }
                    }
                }
            }
            self.tableView.reloadData()
        })
      
    }
    
}//end class


extension FeedVC:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = usersArray[indexPath.row]
        
        let distanceInMeters = currentUserLocation.distanceFromLocation(post.location)
        let distanceInMiles = (distanceInMeters / 1000) * 0.62137
        let stringDistance = String(format: "%.2f", distanceInMiles)
        let passedString = "\(stringDistance) miles away"
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell{
            cell.request?.cancel()
            
            cell.configureCell(post, distance: passedString)
            return cell
        }else{
            return PostCell()
        }
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("The count of the USER array is: \(usersArray.count)")
        return usersArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ChatChat", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ChatChat"{
            print("The current USERID is: \(currentUserUID)")
            let privateChatVC = segue.destinationViewController as! ChatViewController
            privateChatVC.senderId = currentUserUID
            privateChatVC.senderDisplayName = currentUserName
        }
    }
    
}//end extension

