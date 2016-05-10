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

class IntroViewController: UIViewController {
    @IBOutlet weak var videoView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
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
        
        self.createLoginButtons(self.videoView)
    }//end func setupView
    
    func videoDidPlayToEnd(notification: NSNotification){
        let player: AVPlayerItem = notification.object as! AVPlayerItem
        player.seekToTime(kCMTimeZero)
    }//end func videoDidPlayToEnd
    
    func logoTextCenter(containerView: UIView!){
        let half: CGFloat = 1.0 / 2.0
        
        let logoLabel = UILabel()
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
            logoLabel.frame.origin.x = (containerView.frame.size.width - logoLabel.frame.size.width) * half
            logoLabel.frame.origin.y = (containerView.frame.size.height - logoLabel.frame.size.height) * half
        
        containerView.addSubview(logoLabel)
        
        UIView.animateWithDuration(0.5,
                                   delay: 1.5,
                                   options: [],
                                   animations: { logoLabel.alpha = 1.0 },
                                   completion: nil)

    }//end func logoTextCenter
    
    func createLoginButtons(containerView: UIView!){
        let margin: CGFloat = 15.0
        let middleSpacing: CGFloat = 7.5
        
        let signIn = UIButton()
            signIn.alpha = 0.0
            signIn.setTitle("Sign In", forState: .Normal)
            signIn.backgroundColor = PLAYLIFE_COLOR
            signIn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            signIn.titleLabel?.font = UIFont(name: FONT_AVENIR_MEDIUM, size: 18.0)
            
            
            signIn.layer.cornerRadius = 5.0
            signIn.layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
            signIn.layer.shadowOpacity = 0.8
            signIn.layer.shadowRadius = 5.0
            signIn.layer.shadowOffset = CGSizeMake(0.0, 2.0)

        
            signIn.frame.size.width = (((containerView.frame.size.width - signIn.frame.size.width) - (margin * 2)) / 2 - middleSpacing)
            signIn.frame.size.height = 40.0
            signIn.frame.origin.x = margin
            signIn.frame.origin.y = ((containerView.frame.size.height - signIn.frame.size.height) - 25)
            signIn.addTarget(self, action: #selector(IntroViewController.signInButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        containerView.addSubview(signIn)
        
        let register = UIButton()
            register.alpha = 0.0
            register.setTitle("Register", forState: .Normal)
            register.backgroundColor = PLAYLIFE_COLOR
            register.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            register.titleLabel?.font = UIFont(name: FONT_AVENIR_MEDIUM, size: 18.0)
            
            
            register.layer.cornerRadius = 5.0
            register.layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
            register.layer.shadowOpacity = 0.8
            register.layer.shadowRadius = 5.0
            register.layer.shadowOffset = CGSizeMake(0.0, 2.0)

        
            register.frame.size.width = (((containerView.frame.size.width - register.frame.size.width) - (margin * 2)) / 2 - middleSpacing)
            register.frame.size.height = 40.0
            register.frame.origin.x = ((containerView.frame.size.width - register.frame.size.width) - margin)
            register.frame.origin.y = ((containerView.frame.size.height - register.frame.size.height) - 25)
            register.addTarget(self, action: #selector(IntroViewController.registerButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        containerView.addSubview(register)
        
        let fbButton = UIButton()
            fbButton.alpha = 0.0
            fbButton.setTitle("Login With Facebook", forState: .Normal)
            fbButton.backgroundColor = PLAYLIFE_COLOR
            fbButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            fbButton.titleLabel?.font = UIFont(name: FONT_AVENIR_MEDIUM, size: 18.0)
            
            
            fbButton.layer.cornerRadius = 5.0
            fbButton.layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
            fbButton.layer.shadowOpacity = 0.8
            fbButton.layer.shadowRadius = 5.0
            fbButton.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        
            fbButton.frame.size.width = (((containerView.frame.size.width - fbButton.frame.size.width) - (margin * 2)))
            fbButton.frame.size.height = 40.0
            fbButton.frame.origin.x = ((containerView.frame.size.width - fbButton.frame.size.width) - margin)
            fbButton.frame.origin.y = ((containerView.frame.size.height - fbButton.frame.size.height) - 75)
            fbButton.addTarget(self, action: #selector(IntroViewController.fbButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        containerView.addSubview(fbButton)
        
        UIView.animateWithDuration(0.5,
                                   delay: 1.5,
                                   options: [],
                                   animations: { signIn.alpha = 1.0; register.alpha = 1.0; fbButton.alpha = 1.0 },
                                   completion: nil)

    }
    
    func signInButtonPressed(sender:UIButton!){
        print("Let's Sign In")
    }
    
    func registerButtonPressed(sender:UIButton!){
        print("Let's Register")
    }
    
    func fbButtonPressed(sender:UIButton!){
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email","public_profile"], fromViewController: nil) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error: \(facebookError)")
            }else{
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged in with facebook. \(accessToken)")
                
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { error, authData in
                    if error != nil {
                        print("Login Failed. \(error)")
                    }else{
                        print("Logged In! \(authData)")
                        
                        let user = ["provider": authData.provider!, "UserName": "AnonymousPoster", "ProfileImage":"http://imageshack.com/a/img922/8259/MrQ96I.png"]
                        DataService.ds.createFirebaseUser(authData.uid, user: user)
                        
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        //self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }//end else
                })//end withCompletionBlock
            }//end else
        }//end facebook login handler
    }

}

