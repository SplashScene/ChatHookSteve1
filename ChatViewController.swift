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
import MobileCoreServices
import AVKit
import FirebaseStorage

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
                cell.textView?.textColor = UIColor.whiteColor()
            } else {
                cell.textView?.textColor = UIColor.blackColor()
            }
        
        return cell
    }
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    }
    
    func addTextMessage(id: String, text: String) {
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
        let messageItem : [String: AnyObject] = ["fromId": senderId, "text": text, "timestamp" : timestamp, "toId": toId!, "mediaType": "TEXT"]
        
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
    
    override func didPressAccessoryButton(sender: UIButton!) {
        let sheet = UIAlertController(title: "Media Messages", message: "Please select a media", preferredStyle: .ActionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (alert:UIAlertAction) in
            
        }
        let photoLibary = UIAlertAction(title: "Photo Library", style: .Default) { (alert: UIAlertAction) in
            self.getMediaFrom(kUTTypeImage)
        }
        
        let videoLibrary = UIAlertAction(title: "Video Library", style: .Default) { (alert: UIAlertAction) in
            self.getMediaFrom(kUTTypeMovie)
        }
        sheet.addAction(photoLibary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
        self.presentViewController(sheet, animated: true, completion: nil)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        let message = messages[indexPath.item]
        if message.isMediaMessage{
            if let mediaItem = message.media as? JSQVideoMediaItem{
                let player = AVPlayer(URL: mediaItem.fileURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.presentViewController(playerViewController, animated: true, completion: nil)
            }
        }
    }
    
    private func getMediaFrom(type: CFString){
        let mediaPicker = UIImagePickerController()
            mediaPicker.delegate = self
            mediaPicker.mediaTypes = [type as String]
        
        presentViewController(mediaPicker, animated: true, completion: nil)
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
                
                switch (message.mediaType!){
                    case "PHOTO":
                        let url = NSURL(string: message.imageUrl!)
                        let picData = NSData(contentsOfURL: url!)
                        let picture = UIImage(data: picData!)
                        let photo = JSQPhotoMediaItem(image: picture)
                        self.messages.append(JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: photo))
                    case "VIDEO":
                        let video = NSURL(string: message.imageUrl!)
                        let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
                        self.messages.append(JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: videoItem))
                    case "TEXT":
                        self.messages.append(JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, text: message.text!))
                    default:
                        print("unknown data type")
                }
                
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

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            //let jsqMedia = JSQPhotoMediaItem(image: selectedImage)
            //messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: jsqMedia))
            uploadToFirebaseStorageUsingSelectedMedia(selectedImage, video: nil)
        }
        
        if let video = info["UIImagePickerControllerMediaURL"] as? NSURL{
            //let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
            //messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: videoItem))
            uploadToFirebaseStorageUsingSelectedMedia(nil, video: video)
        }

        self.finishSendingMessage()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func uploadToFirebaseStorageUsingSelectedMedia(image: UIImage?, video: NSURL?){
        let imageName = NSUUID().UUIDString
        
        
        if let picture = image{
            let ref = FIRStorage.storage().reference().child("message_images").child(senderId).child("photos").child(imageName)
            if let uploadData = UIImageJPEGRepresentation(picture, 0.2){
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpg"
                ref.putData(uploadData, metadata: metadata, completion: { (metadata, error) in
                    if error != nil{
                        print(error.debugDescription)
                        return
                    }
                    
                    if let imageUrl = metadata?.downloadURL()?.absoluteString{
                        self.sendMessageWithImageUrl(metadata!.contentType!, fileURL:imageUrl)
                    }
                })
            }

        } else if let movie = video {
            let ref = FIRStorage.storage().reference().child("message_images").child(senderId).child("videos").child(imageName)
            if let uploadData = NSData(contentsOfURL: movie){
                let metadata = FIRStorageMetadata()
                    metadata.contentType = "video/mp4"
                ref.putData(uploadData, metadata: metadata, completion: { (metadata, error) in
                    if error != nil{
                        print(error.debugDescription)
                        return
                    }
                    
                    if let imageUrl = metadata?.downloadURL()?.absoluteString{
                        self.sendMessageWithImageUrl(metadata!.contentType!, fileURL:imageUrl)
                    }
                })
            }
            
        }
    }
    
    private func sendMessageWithImageUrl(metadata: String, fileURL: String){
        let toId = user?.postKey
        let itemRef = DataService.ds.REF_MESSAGES.childByAutoId()
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        let messageItem: Dictionary<String,AnyObject>
        
        if metadata == "video/mp4"{
            messageItem = ["fromId": senderId, "imageUrl": fileURL, "timestamp" : timestamp, "toId": toId!, "mediaType": "VIDEO"]
        }else{
            messageItem = ["fromId": senderId, "imageUrl": fileURL, "timestamp" : timestamp, "toId": toId!, "mediaType": "PHOTO"]
        }
        
        
        itemRef.updateChildValues(messageItem) { (error, ref) in
            if error != nil {
                print(error?.description)
                return
            }
            
            let userMessagesRef = DataService.ds.REF_BASE.child("user_messages").child(self.senderId).child(toId!)
            let messageID = itemRef.key
            userMessagesRef.updateChildValues([messageID: 1])
            
            let recipientUserMessagesRef = DataService.ds.REF_BASE.child("user_messages").child(toId!).child(self.senderId)
            recipientUserMessagesRef.updateChildValues([messageID: 1])
        }
        
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
