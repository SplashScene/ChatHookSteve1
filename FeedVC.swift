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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        progressView.hidden = true
        activityIndicatorView.hidden = true
        
        
        tableView.estimatedRowHeight = 65
        let currentUser = DataService.ds.REF_USER_CURRENT
        //let refUsers = DataService.ds.REF_USERS.queryOrderedByChild("Online").queryEqualToValue("true")
        currentUserUID = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        currentUser.observeEventType(.Value, withBlock: {
            snapshot in
            if let myUserName = snapshot.value!.objectForKey("UserName"){
                self.currentUserName = myUserName as! String
            }
            if let myProfilePic = snapshot.value!.objectForKey("ProfileImage"){
                self.currentProfilePicURL = myProfilePic  as! String
            }
        })
        
        DataService.ds.REF_USERS.queryOrderedByChild("Online").observeEventType(.Value, withBlock: {
            snapshot in
            
            self.usersArray = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    if let postDict = snap.value as? Dictionary<String, AnyObject>{
                        let key = snap.key
                        let post = User(postKey: key, dictionary: postDict)
                        self.usersArray.append(post)
                        //print("Added to post array")
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
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell{
            cell.request?.cancel()
            
            cell.configureCell(post)
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

