//
//  ChatViewController.swift
//  ChatHook
//
//  Created by Kevin Farm on 5/27/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
 
    var messages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var messageImage: UIImage!
    var user: User?
    
    var userIsTypingRef: FIRDatabaseReference!
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    var usersTypingQuery: FIRDatabaseQuery!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBubbles()
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        collectionView!.alwaysBounceVertical = true
        automaticallyScrollsToMostRecentMessage = true
        setupNavBarWithUser()
        observeMessages()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }
    
    func setupNavBarWithUser(){
        
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
            profileImageView.image = messageImage
        
        containerView.addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        profileImageView.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        profileImageView.widthAnchor.constraintEqualToConstant(40).active = true
        profileImageView.heightAnchor.constraintEqualToConstant(40).active = true
        
        let nameLabel = UILabel()
            nameLabel.text = user?.userName
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(nameLabel)
        
        nameLabel.leftAnchor.constraintEqualToAnchor(profileImageView.rightAnchor, constant: 8).active = true
        nameLabel.centerYAnchor.constraintEqualToAnchor(profileImageView.centerYAnchor).active = true
        nameLabel.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        nameLabel.heightAnchor.constraintEqualToAnchor(profileImageView.heightAnchor).active = true
        
        containerView.centerXAnchor.constraintEqualToAnchor(titleView.centerXAnchor).active = true
        containerView.centerYAnchor.constraintEqualToAnchor(titleView.centerYAnchor).active = true
        
        self.navigationItem.titleView = titleView
    }

    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
       
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
            if message.senderId == senderId {
                return outgoingBubbleImageView
            } else {
                return incomingBubbleImageView
            }
    }
    
    override func collectionView(collectionView: UICollectionView,cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
            as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
            if message.senderId == senderId {
                cell.textView!.textColor = UIColor.whiteColor()
            } else {
                cell.textView!.textColor = UIColor.blackColor()
            }
        
        return cell
    }
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    }
    
    func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: senderDisplayName, text: text)
        messages.append(message)
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!,
                                     senderDisplayName: String!, date: NSDate!) {
        let toId = user?.postKey
        let itemRef = DataService.ds.REF_MESSAGES.childByAutoId()
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        let messageItem : [String: AnyObject] = ["fromId": senderId, "text": text, "timestamp" : timestamp, "toId": toId!]
        
        //itemRef.setValue(messageItem)
        
        itemRef.updateChildValues(messageItem) { (error, ref) in
            if error != nil {
                print(error?.description)
                return
            }
            
            let userMessagesRef = DataService.ds.REF_BASE.child("user_messages").child(senderId).child(toId!)
            let messageID = itemRef.key
            userMessagesRef.updateChildValues([messageID: 1])
            
            let recipientUserMessagesRef = DataService.ds.REF_BASE.child("user_messages").child(toId!).child(senderId)
            recipientUserMessagesRef.updateChildValues([messageID: 1])
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessageAnimated(true)
        //finishSendingMessage()
        
        isTyping = false
    }
    
    private func observeMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid, toId = user?.postKey else { return }
        let userMessagesRef = DataService.ds.REF_USERMESSAGES.child(uid).child(toId)
        
        userMessagesRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let messageID = snapshot.key
            let messagesRef = DataService.ds.REF_MESSAGES.child(messageID)
            messagesRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                
                let message = Message()
                    message.setValuesForKeysWithDictionary(dictionary)
                let sender = message.fromId
                let msg = message.text
                
                self.addMessage(sender!, text: msg!)
                self.finishReceivingMessageAnimated(true)
                //self.finishReceivingMessage()
                },
                withCancelBlock: nil)

            }, withCancelBlock: nil)
    
        }
    
    private func observeTyping() {
        let typingIndicatorRef = DataService.ds.REF_BASE.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqualToValue(true)
        
        usersTypingQuery.observeEventType(.Value) { (data: FIRDataSnapshot!) in
            
             //3 You're the only typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            // 4 Are there others typing?
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottomAnimated(true)
        }
        
    }
   
}
