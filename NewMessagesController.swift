//
//  NewMessagesController.swift
//  ChatHook
//
//  Created by Kevin Farm on 8/22/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase

class NewMessagesController: UITableViewController {

    
    let cellID = "cellID"
    var usersArray = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(handleCancel))
        
        fetchUser()
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: "cellID")
        
    }
    
    func fetchUser(){
        FIRDatabase.database().reference().child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let userPostKey = snapshot.key
                let user = User(postKey: userPostKey, dictionary: dictionary)
                self.usersArray.append(user)
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
            
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! PostCell
        let user = usersArray[indexPath.row]
        cell.textLabel?.text = user.userName
        cell.detailTextLabel?.text = user.email
        
//        if let profileImageUrl = user.profilePic{
//           // cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
//        }
        
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
