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
    var roomsArray = [PublicRoom]()
    var chosenRoom: PublicRoom?
    let cellID = "cellID"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(RoomsViewController.promptForAddRoom))
        
        title = "Rooms"
        tableView.estimatedRowHeight = 72
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.registerClass(PublicRoomCell.self, forCellReuseIdentifier: cellID)
        
        observeRooms()
    }
    
    func observeRooms(){
        DataService.ds.REF_CHATROOMS.observeEventType(.Value, withBlock: {
            snapshot in
            
            self.roomsArray = []
    
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    if let postDict = snap.value as? Dictionary<String, AnyObject>{
                        let post = PublicRoom(key: snap.key)
                            post.setValuesForKeysWithDictionary(postDict)
                        self.roomsArray.insert(post, atIndex: 0)
                        print("Rooms Array count is: \(self.roomsArray.count)")
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()){
                self.tableView.reloadData()
            }
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
        let authorID = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        //let authorID = FIRAuth.auth()!.currentUser!.uid

        if let unwrappedRoomName = roomName{
            let post: Dictionary<String, AnyObject> =
        
                ["RoomName": unwrappedRoomName,
                 "Author": CurrentUser._userName,
                 "AuthorPic": CurrentUser._profileImageUrl,
                 "timestamp": timestamp,
                 "AuthorID" : authorID]
            
            let firebasePost = DataService.ds.REF_CHATROOMS.childByAutoId()
                firebasePost.setValue(post)
            
            tableView.reloadData()
        }
    }
    
    func showPostControllerForRoom(room: PublicRoom){
        
        let postController = PostsVC()
            postController.roomsController = self
            postController.parentRoom = room
        
            var img: UIImage?
            if let url = room.AuthorPic{
                img = imageCache.objectForKey(url) as? UIImage!
            }
            postController.messageImage = img
        
       // let postNavController = UINavigationController(rootViewController: postController)
           // presentViewController(postNavController, animated: true, completion: nil)
        navigationController?.pushViewController(postController, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = roomsArray[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier(cellID) as? PublicRoomCell{
               cell.publicRoom = post
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
        let room = roomsArray[indexPath.row]
        showPostControllerForRoom(room)
    }
    
    
}//end RoomsViewController





