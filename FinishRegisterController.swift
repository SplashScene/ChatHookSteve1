//
//  FinishRegisterController.swift
//  ChatHook
//
//  Created by Kevin Farm on 8/21/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage


class FinishRegisterController: UIViewController {

    var dbRef: FIRDatabaseReference!
    var introViewController: IntroViewController?
    let currentUser = DataService.ds.REF_USER_CURRENT
    
    let inputsContainerView: UIView = {
        let view = UIView()
            view.backgroundColor = UIColor.whiteColor()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = 5
            view.layer.masksToBounds = true
        return view
    }()
    
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .System)
            button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
            button.setTitle("Register", forState: .Normal)
            button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            button.titleLabel?.font = UIFont.boldSystemFontOfSize(16)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.layer.cornerRadius = 5
            button.layer.masksToBounds = true
            button.addTarget(self, action: #selector(registerButtonTapped), forControlEvents: .TouchUpInside)
        return button
    }()
    
    let userNameTextField: MaterialTextField = {
        let ntf = MaterialTextField()
            ntf.placeholder = "User Name"
            ntf.translatesAutoresizingMaskIntoConstraints = false
        return ntf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
            view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
            view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let fullNameTextField: MaterialTextField = {
        let etf = MaterialTextField()
            etf.placeholder = "Full Name"
            etf.translatesAutoresizingMaskIntoConstraints = false
        return etf
    }()
    
    lazy var profileImageView: MaterialImageView = {
        let imageView = MaterialImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
            imageView.image = UIImage(named: "genericProfile")
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickPhoto)))
            imageView.userInteractionEnabled = true
        return imageView
    }()
    
    let progressView: UIProgressView = { // the progress bar
        let progView = UIProgressView()
            progView.translatesAutoresizingMaskIntoConstraints = false
            progView.hidden = true
        return progView
    }()
    
    let activityIndicator: UIActivityIndicatorView = { //the spinning gear
        let actInd = UIActivityIndicatorView()
            actInd.translatesAutoresizingMaskIntoConstraints = false
            actInd.hidden = true
        return actInd
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(progressView)
        view.addSubview(activityIndicator)
        
        
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
        setupActivity()
        
    }
    
    func setupProfileImageView(){
        //need x, y, width, height constraints
        profileImageView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        profileImageView.bottomAnchor.constraintEqualToAnchor(inputsContainerView.topAnchor, constant: -12).active = true
        profileImageView.widthAnchor.constraintEqualToConstant(150).active = true
        profileImageView.heightAnchor.constraintEqualToConstant(150).active = true
    }
    
    func setupInputsContainerView(){
        //need x, y, width, height constraints
        inputsContainerView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        inputsContainerView.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
        inputsContainerView.widthAnchor.constraintEqualToAnchor(view.widthAnchor, constant: -24).active = true
        inputsContainerView.heightAnchor.constraintEqualToConstant(80).active = true
        
        inputsContainerView.addSubview(userNameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(fullNameTextField)
        
        
        //need x, y, width, height constraints for name text field
        userNameTextField.leftAnchor.constraintEqualToAnchor(inputsContainerView.leftAnchor).active = true
        userNameTextField.topAnchor.constraintEqualToAnchor(inputsContainerView.topAnchor).active = true
        userNameTextField.widthAnchor.constraintEqualToAnchor(inputsContainerView.widthAnchor).active = true
        userNameTextField.heightAnchor.constraintEqualToAnchor(inputsContainerView.heightAnchor, multiplier: 1/2).active = true
        
        //need x, y, width, height constraints for name separator view
        nameSeparatorView.leftAnchor.constraintEqualToAnchor(inputsContainerView.leftAnchor).active = true
        nameSeparatorView.topAnchor.constraintEqualToAnchor(userNameTextField.bottomAnchor).active = true
        nameSeparatorView.widthAnchor.constraintEqualToAnchor(inputsContainerView.widthAnchor).active = true
        nameSeparatorView.heightAnchor.constraintEqualToConstant(1).active = true
        
        //need x, y, width, height constraints for email text field
        fullNameTextField.leftAnchor.constraintEqualToAnchor(inputsContainerView.leftAnchor).active = true
        fullNameTextField.topAnchor.constraintEqualToAnchor(nameSeparatorView.bottomAnchor).active = true
        fullNameTextField.widthAnchor.constraintEqualToAnchor(inputsContainerView.widthAnchor).active = true
        fullNameTextField.heightAnchor.constraintEqualToAnchor(inputsContainerView.heightAnchor, multiplier: 1/2).active = true
    }
    
    func setupLoginRegisterButton(){
        //need x, y, width, height constraints
        loginRegisterButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        loginRegisterButton.topAnchor.constraintEqualToAnchor(inputsContainerView.bottomAnchor, constant: 12).active = true
        loginRegisterButton.widthAnchor.constraintEqualToAnchor(inputsContainerView.widthAnchor).active = true
        loginRegisterButton.heightAnchor.constraintEqualToConstant(50).active = true
    }
    
    func setupActivity(){
        //need x, y, width, height constraints
        progressView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        progressView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: 16).active = true
        progressView.widthAnchor.constraintEqualToAnchor(view.widthAnchor, constant: -16).active = true
        
        activityIndicator.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        activityIndicator.bottomAnchor.constraintEqualToAnchor(progressView.topAnchor, constant: 16).active = true
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func registerButtonTapped() {
        
        guard let userName = userNameTextField.text where userName != "",
            let fullName = fullNameTextField.text where fullName != ""
             else { return }
        
        
        progressView.progress = 0.0
        progressView.hidden = false
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        
        let imageName = NSUUID().UUIDString
        
        let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
        
        if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.2){
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error.debugDescription)
                    return
                }
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                    let values =
                        ["UserName": userName,
                         "ProfileImage": profileImageUrl,
                         "FullName": fullName]
                    
                        self.postRegisteredUserToFirebase(values, progress: {[unowned self] percent in
                        self.progressView.setProgress(percent, animated: true)
                        })
                }
            })
        }
    }
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func postRegisteredUserToFirebase(values:[String: String], progress: (percent: Float) -> Void){
        currentUser.child("UserName").setValue(values["UserName"])
        currentUser.child("FullName").setValue(values["FullName"])
        currentUser.child("ProfileImage").setValue(values["ProfileImage"])
        self.progressView.hidden = true
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
        handleRegisterSegue()
    }
    
    func showErrorAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

    
    func handleRegisterSegue(){
        let tabController = MainTabBar()
            tabController.registerViewController = self
        presentViewController(tabController, animated: true, completion: nil)
    }
    
}//end view controller


