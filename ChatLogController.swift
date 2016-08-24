//
//  ChatLogController.swift
//  ChatHook
//
//  Created by Kevin Farm on 8/17/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate {
    
    var user: User? {
        didSet{
            navigationItem.title = user?.userName
        }
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.placeholder = "Enter Message..."
            textField.delegate = self
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.whiteColor()
        
        setupInputComponents()
    }
    
    func setupInputComponents(){
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        containerView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        containerView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        containerView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        containerView.heightAnchor.constraintEqualToConstant(50).active = true
        
        
        let sendButton = UIButton(type: .System)
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), forControlEvents: .TouchUpInside)
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        sendButton.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        sendButton.widthAnchor.constraintEqualToConstant(80).active = true
        sendButton.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor).active = true
        
        
        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor, constant: 8).active = true
        inputTextField.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        inputTextField.rightAnchor.constraintEqualToAnchor(sendButton.leftAnchor).active = true
        inputTextField.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor).active = true
        
        let separatorLineView = UIView()
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        
        containerView.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        separatorLineView.bottomAnchor.constraintEqualToAnchor(containerView.topAnchor).active = true
        separatorLineView.widthAnchor.constraintEqualToAnchor(containerView.widthAnchor).active = true
        separatorLineView.heightAnchor.constraintEqualToConstant(1).active = true
    }
    
    func handleSend(){
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.postKey
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        let values = ["text" : inputTextField.text!, "toId": toId, "fromId": fromId, "timestamp": timestamp]
        childRef.updateChildValues(values)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
