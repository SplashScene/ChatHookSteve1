//
//  MessagesController.swift
//  ChatHook
//
//  Created by Kevin Farm on 8/22/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase


class MessagesController: UITableViewController {

    let db = FIRDatabase.database().reference()
    var messagesArray = [Message]()
    var messagesDictionary = [String: Message]()
    let cellID = "cellID"
    let currentUserRef = DataService.ds.REF_USER_CURRENT
    var currentUser: User?
    var uid: String?
    var timer: NSTimer?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let newMessageImage = UIImage(named: "newMessageIcon_25")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: newMessageImage, style: .Plain, target: self, action: #selector(handleNewMessage))
        
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: "cellID")
        
        checkIfUserIsLoggedIn()
    }
    
    func observeUserMessages(){
        messagesArray = []
        let ref = db.child("user_messages").child(uid!)
        
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let userID = snapshot.key
            DataService.ds.REF_USERMESSAGES.child(self.uid!).child(userID).observeEventType(.ChildAdded, withBlock: { (snapshot) in
                    let messageID = snapshot.key
                    self.fetchMessageWithMessageId(messageID)
                }, withCancelBlock: nil)
            }, withCancelBlock: nil)
    }
    
    private func fetchMessageWithMessageId(messageID: String){
        let messagesRef = DataService.ds.REF_MESSAGES.child(messageID)
        
        messagesRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let message = Message()
                    message.setValuesForKeysWithDictionary(dictionary)
                    self.messagesArray.append(message)
                    
                    if let chatPartnerID = message.chatPartnerID(){
                        self.messagesDictionary[chatPartnerID] = message
                    }
                    
                    self.attemptReloadOfTable()
                }
            }, withCancelBlock: nil)
    }
    
    private func attemptReloadOfTable(){
        self.timer?.invalidate()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable(){
        self.messagesArray = Array(self.messagesDictionary.values)
        self.messagesArray.sortInPlace({ (message1, message2) -> Bool in
            return message1.timestamp?.intValue > message2.timestamp?.intValue
        })
        dispatch_async(dispatch_get_main_queue()){
            self.tableView.reloadData()
        }
    }
    
    func checkIfUserIsLoggedIn(){
        if FIRAuth.auth()?.currentUser?.uid == nil{
           // performSelector(#selector(handleLogout), withObject: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
            uid = FIRAuth.auth()?.currentUser?.uid
        }
    }
    
    func fetchUserAndSetupNavBarTitle(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        DataService.ds.REF_USERS.child(uid).observeSingleEventOfType(.Value, withBlock: {(snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    self.navigationItem.title = dictionary["name"] as? String
                    let userPostKey = snapshot.key
                    self.currentUser = User(postKey: userPostKey, dictionary: dictionary)
                    self.setupNavBarWithUser(self.currentUser!)
                }
            },
            withCancelBlock: nil)
    }
    
    func setupNavBarWithUser(user: User){
        
        messagesArray.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
            profileImageView.translatesAutoresizingMaskIntoConstraints = false
            profileImageView.contentMode = .ScaleAspectFill
            profileImageView.layer.cornerRadius = 20
            profileImageView.clipsToBounds = true
        if let profileImageUrl = user.profileImageUrl{
            profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        profileImageView.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        profileImageView.widthAnchor.constraintEqualToConstant(40).active = true
        profileImageView.heightAnchor.constraintEqualToConstant(40).active = true
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = user.userName
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.leftAnchor.constraintEqualToAnchor(profileImageView.rightAnchor, constant: 8).active = true
        nameLabel.centerYAnchor.constraintEqualToAnchor(profileImageView.centerYAnchor).active = true
        nameLabel.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        nameLabel.heightAnchor.constraintEqualToAnchor(profileImageView.heightAnchor).active = true
        
        containerView.centerXAnchor.constraintEqualToAnchor(titleView.centerXAnchor).active = true
        containerView.centerYAnchor.constraintEqualToAnchor(titleView.centerYAnchor).active = true
        
        self.navigationItem.titleView = titleView
        
    }
    
    func showChatControllerForUser(user: User){
        let chatLogController = ChatViewController()
            chatLogController.senderId = uid
            chatLogController.senderDisplayName = user.userName
            chatLogController.user = user
        
            var img: UIImage?
            if let url = user.profileImageUrl{
                img = imageCache.objectForKey(url) as? UIImage!
            }
        
            chatLogController.messageImage = img
            
            navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func handleLogout(){
        do{
            try FIRAuth.auth()?.signOut()
        }catch let logoutError{
            print(logoutError)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handleNewMessage(){
        let newMessageController = NewMessagesController()
            newMessageController.messagesController = self
            newMessageController.currentUser = self.currentUser
        let navController = UINavigationController(rootViewController: newMessageController)
        presentViewController(navController, animated: true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! UserCell
        let message = messagesArray[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let message = messagesArray[indexPath.row]
        guard let chatPartnerID = message.chatPartnerID() else { return }
        
        let ref = DataService.ds.REF_USERS.child(chatPartnerID)
        
        ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
                let user = User(postKey: snapshot.key, dictionary: dictionary)
                self.showChatControllerForUser(user)
                },
            withCancelBlock: nil)
        
    }
    
    
}
