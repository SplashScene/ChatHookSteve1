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
    var emailTextField: MaterialTextField!
    var passwordTextField: MaterialTextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil{
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView(){
        let path = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("introVideo", ofType: "mov")!)
        let player = AVPlayer(URL: path)
        
        let newLayer = AVPlayerLayer(player: player)
        newLayer.frame = self.videoView.frame
        self.videoView.layer.addSublayer(newLayer)
        newLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.logoTextCenter(self.videoView)
        player.play()
        
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(IntroViewController.videoDidPlayToEnd(_:)), name: "AVPlayerItemDidPlayToEndTimeNotification", object: player.currentItem)
        
        self.createViews(self.videoView)
        
    }//end func setupView
    
    func videoDidPlayToEnd(notification: NSNotification){
        let player: AVPlayerItem = notification.object as! AVPlayerItem
        player.seekToTime(kCMTimeZero)
    }//end func videoDidPlayToEnd
    
    func logoTextCenter(containerView: UIView!){
        
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
        
        containerView.addSubview(logoLabel)
        
        let logoLabelCenterXConstraint = NSLayoutConstraint(item: logoLabel,
                                                            attribute: NSLayoutAttribute.CenterX,
                                                            relatedBy: NSLayoutRelation.Equal,
                                                            toItem: containerView,
                                                            attribute: NSLayoutAttribute.CenterX,
                                                            multiplier: 1.0,
                                                            constant: 0)
        
        let logoLabelCenterYConstraint = NSLayoutConstraint(item: logoLabel,
                                                            attribute: NSLayoutAttribute.CenterY,
                                                            relatedBy: NSLayoutRelation.Equal,
                                                            toItem: containerView,
                                                            attribute: NSLayoutAttribute.CenterY,
                                                            multiplier: 1.0,
                                                            constant: 0)
        
        UIView.animateWithDuration(0.5,
                                   delay: 1.5,
                                   options: [],
                                   animations: { logoLabel.alpha = 1.0 },
                                   completion: nil)
        
        containerView.addConstraints([logoLabelCenterXConstraint,logoLabelCenterYConstraint])

    }//end func logoTextCenter
    
    func createViews(containerView: UIView!){
        
        
        let facebookView = UIView()
            facebookView.translatesAutoresizingMaskIntoConstraints = false
            facebookView.alpha = 0.0
            facebookView.backgroundColor = UIColor.whiteColor()
            facebookView.layer.cornerRadius = 5.0
            facebookView.layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
            facebookView.layer.shadowOpacity = 0.8
            facebookView.layer.shadowRadius = 5.0
            facebookView.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        
        let fbLogo  = UIImageView()
            fbLogo.translatesAutoresizingMaskIntoConstraints = false
            fbLogo.image = UIImage(named:"fb-icon")
        
        facebookView.addSubview(fbLogo)
        
            facebookLogoConstraints(fbLogo, containerView: facebookView)
        
        
        
        let fbLabel = UILabel()
            fbLabel.translatesAutoresizingMaskIntoConstraints = false
            fbLabel.text = "Login With Facebook"
            fbLabel.font = UIFont(name: "Avenir Medium", size:  24.0)
            fbLabel.backgroundColor = UIColor.clearColor()
            fbLabel.textColor = UIColor.blueColor()
            fbLabel.sizeToFit()
            
            fbLabel.textAlignment = NSTextAlignment.Center

        facebookView.addSubview(fbLabel)
        
            facebookLabelConstraints(fbLabel, containerView: facebookView)
        
        
        let fbButton = UIButton()
            fbButton.translatesAutoresizingMaskIntoConstraints = false
            fbButton.backgroundColor = UIColor.clearColor()
            fbButton.layer.cornerRadius = 5.0
            fbButton.addTarget(self, action: #selector(IntroViewController.fbButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        facebookView.addSubview(fbButton)
        
        fbButtonConstraints(fbButton, containerView: facebookView)

        containerView.addSubview(facebookView)
        
        facebookViewConstraints(facebookView, containerView: containerView)
        
        
        
        let loginView = UIView()
            loginView.translatesAutoresizingMaskIntoConstraints = false
            loginView.alpha = 0.0
            loginView.backgroundColor = UIColor.whiteColor()
            loginView.layer.cornerRadius = 5.0
            loginView.layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
            loginView.layer.shadowOpacity = 0.8
            loginView.layer.shadowRadius = 5.0
            loginView.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        
        
        let loginLabel = UILabel()
            loginLabel.translatesAutoresizingMaskIntoConstraints = false
            loginLabel.alpha = 1.0
            loginLabel.text = "Email Login/Signup"
            loginLabel.font = UIFont(name: "Avenir Medium", size:  18.0)
            loginLabel.backgroundColor = UIColor.clearColor()
            loginLabel.textColor = UIColor.blueColor()
            loginLabel.sizeToFit()
            
            loginLabel.textAlignment = NSTextAlignment.Center
        
        loginView.addSubview(loginLabel)
            loginLabelConstraints(loginLabel, containerView: loginView)
        
            emailTextField = MaterialTextField(frame: CGRect(x:0, y: 0, width: 100, height: 44))
        
            emailTextField.translatesAutoresizingMaskIntoConstraints = false
            emailTextField.placeholder = "email"

        loginView.addSubview(emailTextField)
        
            emailTextFieldConstraints(emailTextField, containerView: loginView)
        
        
            passwordTextField = MaterialTextField()
        
            passwordTextField.translatesAutoresizingMaskIntoConstraints = false
            passwordTextField.placeholder = "password"
        
        loginView.addSubview(passwordTextField)
        
            passwordTextFieldConstraints(passwordTextField, containerView: loginView)
        
        let registerButton = MaterialButton(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
            registerButton.translatesAutoresizingMaskIntoConstraints = false
            registerButton.setTitle("Sign In", forState: .Normal)
            registerButton.addTarget(self, action: #selector(IntroViewController.attemptLogin(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        loginView.addSubview(registerButton)
        loginButtonConstraints(registerButton, containerView: loginView)
        

        
        containerView.addSubview(loginView)
        
            loginViewConstraints(loginView, containerView: containerView)
        
        
        
        UIView.animateWithDuration(0.5,
                                   delay: 1.5,
                                   options: [],
                                   animations: { facebookView.alpha = 0.75;
                                                 loginView.alpha = 0.75},
                                   completion: nil)
    }
    
    func signInButtonPressed(sender:UIButton!){
        print("Let's Sign In")
    }
    
    func registerButtonPressed(sender:UIButton!){
        print("Let's Register")
    }
    
    @IBAction func attemptLogin(sender: UIButton!){
        print("Inside Attempt Login")
        if let email = emailTextField.text where email != "", let pwd = passwordTextField.text where pwd != ""{
//            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authDatafi in
            FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: {(user, error) in
            
                if error != nil{
                    print(error)
                    
                    if error!.code == STATUS_ACCOUNT_NONEXIST{
                        print("Inside ACCOUNT DOESN'T EXIST - \(email) and password: \(pwd)")
                        FIRAuth.auth()?.createUserWithEmail(email, password: pwd, completion: { (user, error) in
                           
                            if error != nil{
                                if error!.code == STATUS_ACCOUNT_WEAKPASSWORD{
                                    self.showErrorAlert("Weak Password", msg: "The password must be 6 characters long or more.")
                                }else{
                                    self.showErrorAlert("Could not create account", msg: "Problem creating account. Try something else")
                                }
                            }else{
                                NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                                
                                    let userData = ["provider": "email", "UserName": "AnonymousPoster","email":self.emailTextField.text!, "ProfileImage":"http://imageshack.com/a/img922/8259/MrQ96I.png"]
                                    DataService.ds.createFirebaseUser(user!.uid, user: userData)
                                
                                self.performSegueWithIdentifier(SEGUE_REGISTER, sender: nil)
                                
                            }
                        })
                    } else if error!.code == STATUS_ACCOUNT_WRONGPASSWORD{
                        self.showErrorAlert("Incorrect Password", msg: "The password that you entered does not match the one we have for your email address")
                    }
                } else {
                    NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID) //set only to allow different signins
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            })
            
        }else{
            showErrorAlert("Email and Password Required", msg: "You must enter an email and password to login")
        }
    }
    
    func showErrorAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "register"{
            let registerVC = segue.destinationViewController as! RegisterVC
            registerVC.emailAddress = emailTextField.text
            registerVC.password = passwordTextField.text
        }
    }
 
    func fbButtonPressed(sender:UIButton!){
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
                        
                        let userData = ["provider": credential.provider, "UserName": "AnonymousPoster", "ProfileImage":"http://imageshack.com/a/img922/8259/MrQ96I.png"]
                        DataService.ds.createFirebaseUser(user!.uid, user: userData)
                        
                        NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                        //self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }//end else
                })//end withCompletionBlock
            }//end else
        }//end facebook login handler
    }
    

//*********************************************** CONSTRAINTS *********************************************
//*********************************************************************************************************
    
    func facebookLabelConstraints(item: UIView, containerView: UIView){
        let fbLabelCenterYConstraint = NSLayoutConstraint(item: item,
                                                          attribute: NSLayoutAttribute.CenterY,
                                                          relatedBy: NSLayoutRelation.Equal,
                                                          toItem: containerView,
                                                          attribute: NSLayoutAttribute.CenterY,
                                                          multiplier: 1.0,
                                                          constant: 0)
        let fbLabelTrailingConstraint = NSLayoutConstraint(item: item,
                                                           attribute: NSLayoutAttribute.Trailing,
                                                           relatedBy: NSLayoutRelation.Equal,
                                                           toItem: containerView,
                                                           attribute: NSLayoutAttribute.TrailingMargin,
                                                           multiplier: 1.0,
                                                           constant: 0)
        containerView.addConstraints([fbLabelCenterYConstraint, fbLabelTrailingConstraint])

    }
    
    func facebookLogoConstraints(item: UIImageView, containerView: UIView){
        let fbLogoHeightConstraint = NSLayoutConstraint(item: item,
                                                        attribute: NSLayoutAttribute.Height,
                                                        relatedBy: NSLayoutRelation.Equal,
                                                        toItem: nil,
                                                        attribute: NSLayoutAttribute.NotAnAttribute,
                                                        multiplier: 1.0,
                                                        constant: 45)
        let fbLogoWidthConstraint = NSLayoutConstraint(item: item,
                                                       attribute: NSLayoutAttribute.Width,
                                                       relatedBy: NSLayoutRelation.Equal,
                                                       toItem: nil,
                                                       attribute: NSLayoutAttribute.NotAnAttribute,
                                                       multiplier: 1.0,
                                                       constant: 45)
        let fbLogoLeadingConstraint = NSLayoutConstraint(item: item,
                                                         attribute: NSLayoutAttribute.Leading,
                                                         relatedBy: NSLayoutRelation.Equal,
                                                         toItem: containerView,
                                                         attribute: NSLayoutAttribute.LeadingMargin,
                                                         multiplier: 1.0,
                                                         constant: 0)
        let fbLogoBottomConstraint = NSLayoutConstraint(item: item,
                                                        attribute: NSLayoutAttribute.Bottom,
                                                        relatedBy: NSLayoutRelation.Equal,
                                                        toItem: containerView,
                                                        attribute: NSLayoutAttribute.Bottom,
                                                        multiplier: 1.0,
                                                        constant: -5)
        
        containerView.addConstraints([fbLogoHeightConstraint,fbLogoWidthConstraint, fbLogoBottomConstraint, fbLogoLeadingConstraint])
    }
    
    func facebookViewConstraints(item: UIView, containerView: UIView){
        let facebookViewLeadingConstraint = NSLayoutConstraint(item: item,
                                                               attribute: NSLayoutAttribute.Leading,
                                                               relatedBy: NSLayoutRelation.Equal,
                                                               toItem: containerView,
                                                               attribute: NSLayoutAttribute.LeadingMargin,
                                                               multiplier: 1.0,
                                                               constant: 0)
        
        let facebookViewTrailingConstraint = NSLayoutConstraint(item: item,
                                                                attribute: NSLayoutAttribute.Trailing,
                                                                relatedBy: NSLayoutRelation.Equal,
                                                                toItem: containerView,
                                                                attribute: NSLayoutAttribute.TrailingMargin,
                                                                multiplier: 1.0,
                                                                constant: 0)
        
        let facebookViewBottomConstraint = NSLayoutConstraint(item: item,
                                                              attribute: NSLayoutAttribute.Bottom,
                                                              relatedBy: NSLayoutRelation.Equal,
                                                              toItem: containerView,
                                                              attribute: NSLayoutAttribute.Bottom,
                                                              multiplier: 1.0,
                                                              constant: -200)
        
        let facebookViewHeightConstraint = NSLayoutConstraint(item: item,
                                                              attribute: NSLayoutAttribute.Height,
                                                              relatedBy: NSLayoutRelation.Equal,
                                                              toItem: nil,
                                                              attribute: NSLayoutAttribute.NotAnAttribute,
                                                              multiplier: 1.0,
                                                              constant: 55)
        
        containerView.addConstraints([facebookViewBottomConstraint,facebookViewHeightConstraint,facebookViewLeadingConstraint, facebookViewTrailingConstraint])

    }
    
    func fbButtonConstraints(item: UIButton, containerView: UIView){
        let fbButtonLeadingConstraint = NSLayoutConstraint(item: item,
                                                           attribute: NSLayoutAttribute.Leading,
                                                           relatedBy: NSLayoutRelation.Equal,
                                                           toItem: containerView,
                                                           attribute: NSLayoutAttribute.Leading,
                                                           multiplier: 1.0,
                                                           constant: 0)
        
        let fbButtonTrailingConstraint = NSLayoutConstraint(item: item,
                                                            attribute: NSLayoutAttribute.Trailing,
                                                            relatedBy: NSLayoutRelation.Equal,
                                                            toItem: containerView,
                                                            attribute: NSLayoutAttribute.Trailing,
                                                            multiplier: 1.0,
                                                            constant: 0)
        
        let fbButtonBottomConstraint = NSLayoutConstraint(item: item,
                                                          attribute: NSLayoutAttribute.Bottom,
                                                          relatedBy: NSLayoutRelation.Equal,
                                                          toItem: containerView,
                                                          attribute: NSLayoutAttribute.Bottom,
                                                          multiplier: 1.0,
                                                          constant: 0)
        
        let fbButtonTopConstraint = NSLayoutConstraint(item: item,
                                                       attribute: NSLayoutAttribute.Top,
                                                       relatedBy: NSLayoutRelation.Equal,
                                                       toItem: containerView,
                                                       attribute: NSLayoutAttribute.Top,
                                                       multiplier: 1.0,
                                                       constant: 0)
        
        containerView.addConstraints([fbButtonBottomConstraint,fbButtonTopConstraint,fbButtonLeadingConstraint, fbButtonTrailingConstraint])

    }
    
    func emailTextFieldConstraints(item: UITextField, containerView: UIView!){
        let emailTextFieldLeadingConstraint = NSLayoutConstraint(item: item,
                                                                 attribute: NSLayoutAttribute.Leading,
                                                                 relatedBy: NSLayoutRelation.Equal,
                                                                 toItem: containerView,
                                                                 attribute: NSLayoutAttribute.LeadingMargin,
                                                                 multiplier: 1.0,
                                                                 constant: 0)
        let emailTextFieldTrailingConstraint = NSLayoutConstraint(item: item,
                                                                  attribute: NSLayoutAttribute.Trailing,
                                                                  relatedBy: NSLayoutRelation.Equal,
                                                                  toItem: containerView,
                                                                  attribute: NSLayoutAttribute.TrailingMargin,
                                                                  multiplier: 1.0,
                                                                  constant: 0)
        
        let emailTextFieldTopConstraint = NSLayoutConstraint(item: item,
                                                             attribute: NSLayoutAttribute.Top,
                                                             relatedBy: NSLayoutRelation.Equal,
                                                             toItem: containerView,
                                                             attribute: NSLayoutAttribute.TopMargin,
                                                             multiplier: 1.0,
                                                             constant: 35)
        let emailTextFieldHeightConstraint = NSLayoutConstraint(item: item,
                                                                attribute: NSLayoutAttribute.Height,
                                                                relatedBy: NSLayoutRelation.Equal,
                                                                toItem: nil,
                                                                attribute: NSLayoutAttribute.NotAnAttribute,
                                                                multiplier: 1.0,
                                                                constant: 35)
        
        containerView.addConstraints([emailTextFieldTopConstraint, emailTextFieldLeadingConstraint, emailTextFieldTrailingConstraint, emailTextFieldHeightConstraint])
        
    }
    
    func passwordTextFieldConstraints(item: UITextField, containerView: UIView!){
        
        let passwordTextFieldLeadingConstraint = NSLayoutConstraint(item: item,
                                                                    attribute: NSLayoutAttribute.Leading,
                                                                    relatedBy: NSLayoutRelation.Equal,
                                                                    toItem: containerView,
                                                                    attribute: NSLayoutAttribute.LeadingMargin,
                                                                    multiplier: 1.0,
                                                                    constant: 0)
        let passwordTextFieldTrailingConstraint = NSLayoutConstraint(item: item,
                                                                     attribute: NSLayoutAttribute.Trailing,
                                                                     relatedBy: NSLayoutRelation.Equal,
                                                                     toItem: containerView,
                                                                     attribute: NSLayoutAttribute.TrailingMargin,
                                                                     multiplier: 1.0,
                                                                     constant: 0)
        
        let passwordTextFieldTopConstraint = NSLayoutConstraint(item: item,
                                                                attribute: NSLayoutAttribute.Top,
                                                                relatedBy: NSLayoutRelation.Equal,
                                                                toItem: containerView,
                                                                attribute: NSLayoutAttribute.TopMargin,
                                                                multiplier: 1.0,
                                                                constant: 75)
        let passwordTextFieldHeightConstraint = NSLayoutConstraint(item: item,
                                                                   attribute: NSLayoutAttribute.Height,
                                                                   relatedBy: NSLayoutRelation.Equal,
                                                                   toItem: nil,
                                                                   attribute: NSLayoutAttribute.NotAnAttribute,
                                                                   multiplier: 1.0,
                                                                   constant: 35)
        
        containerView.addConstraints([passwordTextFieldLeadingConstraint, passwordTextFieldTrailingConstraint, passwordTextFieldTopConstraint, passwordTextFieldHeightConstraint])
    }
    
    func loginViewConstraints(item: UIView, containerView: UIView){
        let loginViewLeadingConstraint = NSLayoutConstraint(item: item,
                                                            attribute: NSLayoutAttribute.Leading,
                                                            relatedBy: NSLayoutRelation.Equal,
                                                            toItem: containerView,
                                                            attribute: NSLayoutAttribute.LeadingMargin,
                                                            multiplier: 1.0,
                                                            constant: 0)
        
        let loginViewTrailingConstraint = NSLayoutConstraint(item: item,
                                                             attribute: NSLayoutAttribute.Trailing,
                                                             relatedBy: NSLayoutRelation.Equal,
                                                             toItem: containerView,
                                                             attribute: NSLayoutAttribute.TrailingMargin,
                                                             multiplier: 1.0,
                                                             constant: 0)
        
        let loginViewBottomConstraint = NSLayoutConstraint(item: item,
                                                           attribute: NSLayoutAttribute.Bottom,
                                                           relatedBy: NSLayoutRelation.Equal,
                                                           toItem: containerView,
                                                           attribute: NSLayoutAttribute.Bottom,
                                                           multiplier: 1.0,
                                                           constant: -15)
        
        let loginViewHeightConstraint = NSLayoutConstraint(item: item,
                                                           attribute: NSLayoutAttribute.Height,
                                                           relatedBy: NSLayoutRelation.Equal,
                                                           toItem: nil,
                                                           attribute: NSLayoutAttribute.NotAnAttribute,
                                                           multiplier: 1.0,
                                                           constant: 180)
        
        containerView.addConstraints([loginViewBottomConstraint,loginViewHeightConstraint,loginViewLeadingConstraint, loginViewTrailingConstraint])

    }
    
    func loginLabelConstraints(item: UILabel, containerView: UIView){
        let loginLabelLeadingConstraint = NSLayoutConstraint(item: item,
                                                             attribute: NSLayoutAttribute.Leading,
                                                             relatedBy: NSLayoutRelation.Equal,
                                                             toItem: containerView,
                                                             attribute: NSLayoutAttribute.LeadingMargin,
                                                             multiplier: 1.0,
                                                             constant: 0)
        let loginLabelTopConstraint = NSLayoutConstraint(item: item,
                                                         attribute: NSLayoutAttribute.Top,
                                                         relatedBy: NSLayoutRelation.Equal,
                                                         toItem: containerView,
                                                         attribute: NSLayoutAttribute.TopMargin,
                                                         multiplier: 1.0,
                                                         constant: 0)
        containerView.addConstraints([loginLabelTopConstraint, loginLabelLeadingConstraint])

    }
    
    func loginButtonConstraints(item: UIButton, containerView: UIView){
        let loginButtonCenterXConstraint = NSLayoutConstraint(item: item,
                                                            attribute: NSLayoutAttribute.CenterX,
                                                            relatedBy: NSLayoutRelation.Equal,
                                                            toItem: containerView,
                                                            attribute: NSLayoutAttribute.CenterX,
                                                            multiplier: 1.0,
                                                            constant: 0)
        let loginButtonHeightConstraint = NSLayoutConstraint(item: item,
                                                              attribute: NSLayoutAttribute.Height,
                                                              relatedBy: NSLayoutRelation.Equal,
                                                              toItem: nil,
                                                              attribute: NSLayoutAttribute.NotAnAttribute,
                                                              multiplier: 1.0,
                                                              constant: 35)
        let loginButtonWidthConstraint = NSLayoutConstraint(item: item,
                                                             attribute: NSLayoutAttribute.Width,
                                                             relatedBy: NSLayoutRelation.Equal,
                                                             toItem: nil,
                                                             attribute: NSLayoutAttribute.NotAnAttribute,
                                                             multiplier: 1.0,
                                                             constant: 125)
        let loginButtonBottomConstraint = NSLayoutConstraint(item: item,
                                                           attribute: NSLayoutAttribute.Bottom,
                                                           relatedBy: NSLayoutRelation.Equal,
                                                           toItem: containerView,
                                                           attribute: NSLayoutAttribute.Bottom,
                                                           multiplier: 1.0,
                                                           constant: -10)
        containerView.addConstraints([loginButtonCenterXConstraint, loginButtonHeightConstraint,loginButtonWidthConstraint,loginButtonBottomConstraint])
        
    }


}

