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
    var rawMessages = [Message]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var messageImage: UIImage!
    var user: User?
    var currentUserUID = FIRAuth.auth()?.currentUser?.uid
    
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
        setupNavBarWithUserOrProgress(nil)
        observeMessages()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.inputToolbar.barTintColor = UIColor.whiteColor()
    }
    
    func setupNavBarWithUserOrProgress(progress:String?){
        
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
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
            if let progressText = progress{
                nameLabel.text = progressText
                nameLabel.textColor = UIColor.redColor()
            }else{
                nameLabel.text = user?.userName
                nameLabel.textColor = UIColor.darkGrayColor()
            }
        
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
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleLightGrayColor())
    }

    
//MARK: Collection Views
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        
       return message.senderId == currentUserUID ? outgoingBubbleImageView : incomingBubbleImageView

    }
    
    //var cell:JSQMessagesCollectionViewCell?
    var message:JSQMessage?
    var playButton: UIButton?
    
    override func collectionView(collectionView: UICollectionView,cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as? JSQMessagesCollectionViewCell
            cell?.delegate = self
        message = messages[indexPath.item]
        let rawMessage = rawMessages[indexPath.item]
 
           if rawMessage.mediaType == "VIDEO"{
            
            if cell?.mediaView.subviews.count > 0{
                for view in (cell?.mediaView.subviews)!{
                    view.removeFromSuperview()
                }
            }
 
            let thumbImageView = UIImageView()
                thumbImageView.loadImageUsingCacheWithUrlString(rawMessage.thumbnailUrl!)
                thumbImageView.translatesAutoresizingMaskIntoConstraints = false
                thumbImageView.contentMode = .ScaleAspectFill
            
            let image = UIImage(named: "playButton")
            
                playButton = UIButton()
                playButton!.translatesAutoresizingMaskIntoConstraints = false
                playButton!.setImage(image, forState: .Normal)
            
                cell!.mediaView.addSubview(thumbImageView)
            
                thumbImageView.widthAnchor.constraintEqualToAnchor(cell!.widthAnchor).active = true
                thumbImageView.heightAnchor.constraintEqualToAnchor(cell!.heightAnchor).active = true
 
                 cell!.mediaView.addSubview(playButton!)
            
                playButton!.centerXAnchor.constraintEqualToAnchor(cell!.mediaView.centerXAnchor).active = true
                playButton!.centerYAnchor.constraintEqualToAnchor(cell!.mediaView.centerYAnchor).active = true
                playButton!.widthAnchor.constraintEqualToConstant(50).active = true
                playButton!.heightAnchor.constraintEqualToConstant(50).active = true
            
                let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
                    activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
                    activityIndicatorView.hidesWhenStopped = true
                    //activityIndicatorView.startAnimating()
            
                cell!.mediaView.addSubview(activityIndicatorView)
                
                activityIndicatorView.centerXAnchor.constraintEqualToAnchor(cell!.mediaView.centerXAnchor).active = true
                activityIndicatorView.centerYAnchor.constraintEqualToAnchor(cell!.mediaView.centerYAnchor).active = true
                activityIndicatorView.widthAnchor.constraintEqualToConstant(50).active = true
                activityIndicatorView.heightAnchor.constraintEqualToConstant(50).active = true
            
            }
        

        cell!.textView?.textColor = message!.senderId == currentUserUID ? UIColor.whiteColor() : UIColor.blackColor()
        
        return cell!
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    private func setupVideoCell(){
        
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
            sheet.dismissViewControllerAnimated(true, completion: nil)
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
    
    private func getMediaFrom(type: CFString){
        let mediaPicker = UIImagePickerController()
            mediaPicker.delegate = self
            mediaPicker.mediaTypes = [type as String]
        
        presentViewController(mediaPicker, animated: true, completion: nil)
    }
    
    //MARK: Observe Methods
    
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
                    self.rawMessages.append(message)
                
                    //let senderName = self.observeUser(message.fromId!)
                
                switch (message.mediaType!){
                    case "PHOTO":
                        let url = NSURL(string: message.imageUrl!)
                        let picData = NSData(contentsOfURL: url!)
                        let picture = UIImage(data: picData!)
                        let photo = JSQPhotoMediaItem(image: picture)
                        self.messages.append(JSQMessage(senderId: message.fromId, displayName: self.senderDisplayName, media: photo))
                        photo.appliesMediaViewMaskAsOutgoing = message.fromId == self.currentUserUID ? true : false
                    
                    case "VIDEO":
                        let video = NSURL(string: message.imageUrl!)
                        let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
                        self.messages.append(JSQMessage(senderId: message.fromId, displayName: self.senderDisplayName, media: videoItem))
                        videoItem.appliesMediaViewMaskAsOutgoing = message.fromId == self.currentUserUID ? true : false
                    
                    case "TEXT":
                        self.messages.append(JSQMessage(senderId: message.fromId, displayName: self.senderDisplayName, text: message.text!))
                    
                    default:
                        print("unknown data type")
                }
                
                self.finishReceivingMessageAnimated(true)
                //self.finishReceivingMessage()
                },
                withCancelBlock: nil)

            }, withCancelBlock: nil)
    
        }
    /*
    private func observeUser(id: String) -> String{
        var userDisplayName: String?
        let userRef = DataService.ds.REF_USERS.child(id)
        userRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                if let displayName = dictionary["UserName"] as? String{
                    userDisplayName = displayName
                    print("Inside userDisplayName is: \(userDisplayName)")
                }
            }
            }, withCancelBlock: nil)
        print("Outside userDisplayName is: \(userDisplayName)")
        return "Kevin Farm"
    }
    */
    
    //MARK: Typing Indicator Methods
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
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
    
    //MARK: Image Zoom Methods
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingView: UIView?
    
    func performZoomInForStartingImageView(startingView: UIView, photoImage: JSQPhotoMediaItem){
        self.startingView = startingView
        
        startingFrame = startingView.superview?.convertRect(startingView.frame, toView: nil)
        
        let zoomingView = UIImageView(frame: startingFrame!)
        zoomingView.backgroundColor = UIColor.redColor()
        zoomingView.userInteractionEnabled = true
        zoomingView.contentMode = .ScaleAspectFill
        zoomingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        zoomingView.image = photoImage.image
        if let keyWindow = UIApplication.sharedApplication().keyWindow{
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.blackColor()
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingView)
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {
                self.blackBackgroundView!.alpha = 1
                self.inputToolbar.alpha = 0
                self.startingView?.hidden = true
                
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingView.center = keyWindow.center
                }, completion: nil)
        }
        
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomOutImageView = tapGesture.view{
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputToolbar.alpha = 1
                }, completion: { (completed) in
                    zoomOutImageView.removeFromSuperview()
                    self.startingView?.hidden = false
            })
        }
    }

}

extension ChatViewController: JSQMessagesCollectionViewCellDelegate{
    
    func messagesCollectionViewCellDidTapMessageBubble(cell: JSQMessagesCollectionViewCell!) {
        let cellIndexPath = super.collectionView.indexPathForCell(cell)
        let message = messages[(cellIndexPath?.item)!]
        
        if message.isMediaMessage{
            if let mediaItem = message.media as? JSQVideoMediaItem{
                
                let pButton = cell!.mediaView.subviews[1] as? UIButton
                    pButton?.hidden = true
                let cellAIV = cell!.mediaView.subviews[2] as? UIActivityIndicatorView
                    cellAIV?.startAnimating()
                let player = AVPlayer(URL: mediaItem.fileURL)
                let playerLayer = AVPlayerLayer(player: player)
                    playerLayer.videoGravity = AVLayerVideoGravityResize
                    playerLayer.masksToBounds = true
                
                cell!.mediaView.layer.addSublayer(playerLayer)
                playerLayer.frame = cell!.mediaView.bounds
                player.play()
                
            }else if let photoImage = message.media as? JSQPhotoMediaItem{
                performZoomInForStartingImageView(cell.mediaView, photoImage: photoImage)
            }
        }
    }
    
    func messagesCollectionViewCellDidTapAvatar(cell: JSQMessagesCollectionViewCell!) {
        print("Did tap Avatar")
    }
    
    func messagesCollectionViewCellDidTapCell(cell: JSQMessagesCollectionViewCell!, atPosition position: CGPoint) {
        print("Did tap Collection Cell")
    }
    
    func messagesCollectionViewCell(cell: JSQMessagesCollectionViewCell!, didPerformAction action: Selector, withSender sender: AnyObject!) {
        print("Inside didPerformAction")
    }
 
}


