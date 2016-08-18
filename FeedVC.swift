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
    var messageUserName: String?
    var messageProfilePicURL: String?
    var messagedUser: User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        progressView.hidden = true
        activityIndicatorView.hidden = true
        tableView.estimatedRowHeight = 65
        
        getCurrentUser()
        getAllUsersOnline()
        
    }
    
    func getCurrentUser(){
        let currentUser = DataService.ds.REF_USER_CURRENT
        
        currentUser.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                self.currentUserUID = snapshot.key
                if let myUserName = dictionary["UserName"] as? String,
                    let myProfilePic = dictionary["ProfileImage"] as? String,
                    let userLat = dictionary["UserLatitude"] as? Double,
                    let userLong = dictionary["UserLongitude"] as? Double{
                        self.currentUserName = myUserName
                        self.currentProfilePicURL = myProfilePic
                        self.currentUserLocation = CLLocation(latitude: userLat, longitude: userLong)
                }
            }
        }, withCancelBlock: nil)
    }//end getCurrentUser
    
    func getAllUsersOnline(){
        DataService.ds.REF_USERS.observeEventType(.Value, withBlock: {
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
        let distanceString = calculateDistance(post.location)
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell{
            cell.request?.cancel()
            var img: UIImage?
            
            if let url = post.profilePic{
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(post, img:img, distance: distanceString)
            return cell
        }else{
            return PostCell()
        }
        
    }
       
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        messagedUser = usersArray[indexPath.row]
        messageProfilePicURL = messagedUser?.profilePic
        performSegueWithIdentifier("ChatChat", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ChatChat"{
            var img: UIImage?
            if let url = messageProfilePicURL{
                img = (FeedVC.imageCache.objectForKey(url) as? UIImage)!
            }
            let privateChatVC = segue.destinationViewController as! ChatViewController
                privateChatVC.senderId = currentUserUID
                privateChatVC.senderDisplayName = currentUserName
                privateChatVC.messageImage = img
                privateChatVC.user = messagedUser
        }
    }
    
    func calculateDistance(otherLocation: CLLocation) -> String {
        let distanceInMeters = currentUserLocation.distanceFromLocation(otherLocation)
        let distanceInMiles = (distanceInMeters / 1000) * 0.62137
        let stringDistance = String(format: "%.2f", distanceInMiles)
        let passedString = "\(stringDistance) miles away"
        return passedString
    }
    
}//end extension

