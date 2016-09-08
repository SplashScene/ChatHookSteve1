//
//  ViewController.swift
//  ChatHook
//
//  Created by Kevin Farm on 5/10/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase


class IntroViewController: UIViewController {
    @IBOutlet weak var videoView: UIView!
    
    let chatHookLogo: UILabel = {
        let logoLabel = UILabel()
            logoLabel.translatesAutoresizingMaskIntoConstraints = false
            logoLabel.alpha = 0.0
            logoLabel.text = "ChatHook"
            logoLabel.font = UIFont(name: "Avenir Medium", size:  60.0)
            logoLabel.backgroundColor = UIColor.clearColor()
            logoLabel.textColor = UIColor.whiteColor()
            logoLabel.sizeToFit()
            logoLabel.layer.shadowOffset = CGSize(width: 3, height: 3)
            logoLabel.layer.shadowOpacity = 0.7
            logoLabel.layer.shadowRadius = 2
            logoLabel.textAlignment = NSTextAlignment.Center
        return logoLabel
    }()
    
    lazy var facebookContainerView: UIView = {
        let facebookView = UIView()
            facebookView.translatesAutoresizingMaskIntoConstraints = false
            facebookView.alpha = 0.0
            facebookView.backgroundColor = UIColor.whiteColor()
            facebookView.layer.cornerRadius = 5.0
            facebookView.layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
            facebookView.layer.shadowOpacity = 0.8
            facebookView.layer.shadowRadius = 5.0
            facebookView.layer.shadowOffset = CGSizeMake(0.0, 2.0)
            facebookView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fbButtonPressed)))
        return facebookView
    }()
    
    let facebookLogoView: UIImageView = {
        let fbLogo  = UIImageView()
            fbLogo.translatesAutoresizingMaskIntoConstraints = false
            fbLogo.image = UIImage(named:"fb-icon")
        return fbLogo
    }()
    
    let facebookLabel: UILabel = {
        let fbLabel = UILabel()
            fbLabel.translatesAutoresizingMaskIntoConstraints = false
            fbLabel.text = "Login With Facebook"
            fbLabel.font = UIFont(name: "Avenir Medium", size:  24.0)
            fbLabel.backgroundColor = UIColor.clearColor()
            fbLabel.textColor = UIColor.blueColor()
            fbLabel.sizeToFit()
            fbLabel.textAlignment = NSTextAlignment.Center
        return fbLabel
    }()
    
    let loginContainerView: UIView = {
        let loginView = UIView()
            loginView.translatesAutoresizingMaskIntoConstraints = false
            loginView.alpha = 0.0
            loginView.backgroundColor = UIColor.whiteColor()
            loginView.layer.cornerRadius = 5.0
            loginView.layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
            loginView.layer.shadowOpacity = 0.8
            loginView.layer.shadowRadius = 5.0
            loginView.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        return loginView
    }()
    
    let inputsContainerView: UIView = {
        let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = 5
            view.layer.masksToBounds = true
        return view
    }()

    
    let loginLabel: UILabel = {
        let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.alpha = 1.0
            label.text = "Email Login/Signup"
            label.font = UIFont(name: "Avenir Medium", size:  18.0)
            label.backgroundColor = UIColor.clearColor()
            label.textColor = UIColor.blueColor()
            label.sizeToFit()
            label.textAlignment = NSTextAlignment.Center
        return label

    }()
    
    let emailTextField: MaterialTextField = {
        let etf = MaterialTextField()
            etf.placeholder = "Email"
            etf.translatesAutoresizingMaskIntoConstraints = false
            etf.autocapitalizationType = .None
        return etf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
            view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
            view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordTextField: MaterialTextField = {
        let ptf = MaterialTextField()
            ptf.placeholder = "Password"
            ptf.secureTextEntry = true
            ptf.autocapitalizationType = .None
            ptf.translatesAutoresizingMaskIntoConstraints = false
        return ptf
    }()
    
    lazy var registerButton: MaterialButton = {
        let button = MaterialButton(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Sign In", forState: .Normal)
            button.addTarget(self, action: #selector(attemptLogin), forControlEvents: UIControlEvents.TouchUpInside)
        return button
    }()

    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        //NSUserDefaults.standardUserDefaults().setValue("q3KcxAnXh9SXAe9UshCKvPteXgq1", forKey: KEY_UID)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil{
//            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
//        }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func setupView(){
        let path = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("introVideo", ofType: "mov")!)
        let player = AVPlayer(URL: path)
        
        let newLayer = AVPlayerLayer(player: player)
            newLayer.frame = self.videoView.frame
        self.videoView.layer.addSublayer(newLayer)
            newLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        //self.logoTextCenter(self.videoView)
        player.play()
        
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(IntroViewController.videoDidPlayToEnd(_:)), name: "AVPlayerItemDidPlayToEndTimeNotification", object: player.currentItem)
        
        self.videoView.addSubview(chatHookLogo)
        self.videoView.addSubview(facebookContainerView)
        self.videoView.addSubview(loginContainerView)
        
        setupChatHookLogoView()
        setupFacebookContainerView()
        setupLoginContainerView()
        
        //self.createViews(self.videoView)
        
    }//end func setupView
    
    func videoDidPlayToEnd(notification: NSNotification){
        let player: AVPlayerItem = notification.object as! AVPlayerItem
            player.seekToTime(kCMTimeZero)
    }//end func videoDidPlayToEnd
    
    func setupChatHookLogoView(){
        //need x, y, width and height constraints
        chatHookLogo.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        chatHookLogo.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
        UIView.animateWithDuration(0.5,
                                   delay: 1.5,
                                   options: [],
                                   animations: { self.chatHookLogo.alpha = 1.0 },
                                   completion: nil)
    }
    
    func setupFacebookContainerView(){
        //need x, y, width and height constraints
        facebookContainerView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        facebookContainerView.topAnchor.constraintEqualToAnchor(chatHookLogo.bottomAnchor, constant: 8).active = true
        facebookContainerView.widthAnchor.constraintEqualToAnchor(view.widthAnchor, constant: -24).active = true
        facebookContainerView.heightAnchor.constraintEqualToConstant(55).active = true
        
        facebookContainerView.addSubview(facebookLogoView)
        facebookContainerView.addSubview(facebookLabel)
        
        facebookLogoView.leftAnchor.constraintEqualToAnchor(facebookContainerView.leftAnchor, constant: 8).active = true
        facebookLogoView.centerYAnchor.constraintEqualToAnchor(facebookContainerView.centerYAnchor).active = true
        facebookLogoView.widthAnchor.constraintEqualToConstant(45).active = true
        facebookLogoView.heightAnchor.constraintEqualToConstant(45).active = true
        
        facebookLabel.centerXAnchor.constraintEqualToAnchor(facebookContainerView.centerXAnchor).active = true
        facebookLabel.centerYAnchor.constraintEqualToAnchor(facebookContainerView.centerYAnchor).active = true
        facebookLabel.widthAnchor.constraintEqualToConstant(250).active = true
        facebookLabel.heightAnchor.constraintEqualToAnchor(facebookContainerView.heightAnchor).active = true
    }
    
    func setupLoginContainerView(){
        //need x, y, width and height constraints
        loginContainerView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        loginContainerView.topAnchor.constraintEqualToAnchor(facebookContainerView.bottomAnchor, constant: 15).active = true
        loginContainerView.widthAnchor.constraintEqualToAnchor(view.widthAnchor, constant: -24).active = true
        loginContainerView.heightAnchor.constraintEqualToConstant(180).active = true
        
        loginContainerView.addSubview(inputsContainerView)
        loginContainerView.addSubview(loginLabel)
        loginContainerView.addSubview(registerButton)
        
        inputsContainerView.centerXAnchor.constraintEqualToAnchor(loginContainerView.centerXAnchor).active = true
        inputsContainerView.centerYAnchor.constraintEqualToAnchor(loginContainerView.centerYAnchor).active = true
        inputsContainerView.widthAnchor.constraintEqualToAnchor(loginContainerView.widthAnchor, constant: -24).active = true
        inputsContainerView.heightAnchor.constraintEqualToConstant(80).active = true
        
        
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        //need x, y, width, height constraints for login label - size to fit
        loginLabel.leftAnchor.constraintEqualToAnchor(loginContainerView.leftAnchor, constant: 8).active = true
        loginLabel.topAnchor.constraintEqualToAnchor(loginContainerView.topAnchor, constant: 8).active = true
        
        //need x, y, width, height constraints for email text field
        emailTextField.leftAnchor.constraintEqualToAnchor(inputsContainerView.leftAnchor).active = true
        emailTextField.topAnchor.constraintEqualToAnchor(inputsContainerView.topAnchor).active = true
        emailTextField.widthAnchor.constraintEqualToAnchor(inputsContainerView.widthAnchor).active = true
        emailTextField.heightAnchor.constraintEqualToAnchor(inputsContainerView.heightAnchor, multiplier: 1/2).active = true
        
        //need x, y, width, height constraints for email separator view
        emailSeparatorView.leftAnchor.constraintEqualToAnchor(inputsContainerView.leftAnchor).active = true
        emailSeparatorView.topAnchor.constraintEqualToAnchor(emailTextField.bottomAnchor).active = true
        emailSeparatorView.widthAnchor.constraintEqualToAnchor(inputsContainerView.widthAnchor).active = true
        emailSeparatorView.heightAnchor.constraintEqualToConstant(1).active = true
        
        //need x, y, width, height constraints for password text field
        passwordTextField.leftAnchor.constraintEqualToAnchor(inputsContainerView.leftAnchor).active = true
        passwordTextField.topAnchor.constraintEqualToAnchor(emailSeparatorView.bottomAnchor).active = true
        passwordTextField.widthAnchor.constraintEqualToAnchor(inputsContainerView.widthAnchor).active = true
        passwordTextField.heightAnchor.constraintEqualToAnchor(inputsContainerView.heightAnchor, multiplier: 1/2).active = true
        
        //need x, y, width, height constraints for login label - size to fit
        registerButton.rightAnchor.constraintEqualToAnchor(loginContainerView.rightAnchor, constant: -8).active = true
        registerButton.bottomAnchor.constraintEqualToAnchor(loginContainerView.bottomAnchor, constant: -8).active = true
        registerButton.widthAnchor.constraintEqualToConstant(125).active = true
        registerButton.heightAnchor.constraintEqualToConstant(35).active = true


        
        UIView.animateWithDuration(0.5,
                                   delay: 1.5,
                                   options: [],
                                   animations: { self.facebookContainerView.alpha = 0.75;
                                                 self.loginContainerView.alpha = 0.75},
                                   completion: nil)
    }
    
    func fbButtonPressed(){
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email","public_profile"], fromViewController: nil) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error: \(facebookError)")
            }else{
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged in with facebook. \(accessToken)")
                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    if error != nil {
                        print("Login Failed. \(error)")
                    }else{
                        print("Logged In! \(user)")
                        
                        let userData = ["provider": credential.provider,
                                        "UserName": "AnonymousPoster",
                                        "ProfileImage":"http://imageshack.com/a/img922/8259/MrQ96I.png"]
                        DataService.ds.createFirebaseUser(user!.uid, user: userData )
                        
                        NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                        //self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }//end else
                })//end withCompletionBlock
            }//end else
        }//end facebook login handler
    }
    
    func attemptLogin(){
        print("Inside Attempt Login")
        
        guard let email = emailTextField.text, password = passwordTextField.text else {
            showErrorAlert("Email and Password Required", msg: "You must enter an email and password to login")
            return
        }
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: {(user, error) in
            
            if error != nil{
                print(error)
                
                if error!.code == STATUS_NO_INTERNET{
                    print("There is no internet connection")
                    self.showErrorAlert("No Internet Connection", msg: "You currently have no internet connection. Please try again later.")
                }
                
                if error!.code == STATUS_ACCOUNT_NONEXIST{
                    print("Inside ACCOUNT DOESN'T EXIST - \(email) and password: \(password)")
                    FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
                        
                        if error != nil{
                            error!.code == STATUS_ACCOUNT_WEAKPASSWORD ?
                                self.showErrorAlert("Weak Password", msg: "The password must be more than 5 characters.") :
                                self.showErrorAlert("Could not create account",
                                    msg: "Problem creating account. Try something else")
                        }else{
                            NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                            
                            let userData = ["provider": "email",
                                            "UserName": "AnonymousPoster",
                                            "email": email,
                                            "ProfileImage":"http://imageshack.com/a/img922/8259/MrQ96I.png"]
                            
                            DataService.ds.createFirebaseUser(user!.uid, user: userData)
                            
                            self.handleRegisterSegue()
                        }
                    })
                } else if error!.code == STATUS_ACCOUNT_WRONGPASSWORD{
                    self.showErrorAlert("Incorrect Password", msg: "The password that you entered does not match the one we have for your email address")
                }
            } else {
                //set only to allow different signins
                NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                self.handleReturningUser()
                
            }
        })
    }
    
    func showErrorAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func handleRegisterSegue(){
        let loginController = FinishRegisterController()
        loginController.introViewController = self
        presentViewController(loginController, animated: true, completion: nil)
    }
    
    func handleReturningUser(){
        let tabController = MainTabBar()
        tabController.introViewController = self
        presentViewController(tabController, animated: true, completion: nil)
    }
    

}//end class


extension UIColor{
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
