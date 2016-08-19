//
//  RoomsViewController.swift
//  ChatHook
//
//  Created by Kevin Farm on 7/18/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase

class RoomsViewController: UITableViewController {
    var currentUserName: String!
    var currentProfilePicURL: String!
    var roomsArray = [PublicRoom]()
    var chosenRoom: PublicRoom?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(RoomsViewController.promptForAddRoom))
        
        title = "Public Rooms"
        tableView.estimatedRowHeight = 65
        tableView.delegate = self
        tableView.dataSource = self
        
        let currentUser = DataService.ds.REF_USER_CURRENT
        
        currentUser.observeEventType(.Value, withBlock: {
            snapshot in
            if let myUserName = snapshot.value!.objectForKey("UserName"){
                self.currentUserName = myUserName as! String
            }
            if let myProfilePic = snapshot.value!.objectForKey("ProfileImage"){
                self.currentProfilePicURL = myProfilePic  as! String
            }
            
        })
        
        DataService.ds.REF_CHATROOMS.observeEventType(.Value, withBlock: {
            snapshot in
            
            self.roomsArray = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    if let postDict = snap.value as? Dictionary<String, AnyObject>{
                        let key = snap.key
                        let post = PublicRoom(postKey: key, dictionary: postDict)
                        self.roomsArray.insert(post, atIndex: 0)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }

    func promptForAddRoom(){
        let ac = UIAlertController(title: "Enter Room Name", message: "What is the name of your public room?", preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler{ (textField: UITextField) in
            textField.placeholder = "You Room Name"
        }
        
        ac.addAction(UIAlertAction(title: "Submit", style: .Default){[unowned self, ac](action: UIAlertAction!) in
                let roomName = ac.textFields![0]
                self.postToFirebase(roomName.text!)
            })
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func postToFirebase(roomName: String?){
        let timestamp: NSNumber = NSDate().timeIntervalSince1970
        let authorID = FIRAuth.auth()!.currentUser!.uid

        if let unwrappedRoomName = roomName{
            let post: Dictionary<String, AnyObject> =
                
                ["RoomName": unwrappedRoomName,
                 "Author": currentUserName,
                 "AuthorPic": currentProfilePicURL,
                 "timestamp": timestamp,
                 "AuthorID" : authorID]
            
            let firebasePost = DataService.ds.REF_CHATROOMS.childByAutoId()
            firebasePost.setValue(post)
            
            tableView.reloadData()
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = roomsArray[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("RoomCell") as? PublicRoomCell{
            cell.request?.cancel()
            cell.configureCell(post)
            return cell
        }else{
            return PublicRoomCell()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomsArray.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        chosenRoom = roomsArray[indexPath.row]
        performSegueWithIdentifier("GoToChatPost", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GoToChatPost"{
            let publicPosts = segue.destinationViewController as! PostsVC
            
            publicPosts.roomID = chosenRoom?.postKey
            publicPosts.roomName = chosenRoom?.roomName
        }
    }

}//end RoomsViewController





