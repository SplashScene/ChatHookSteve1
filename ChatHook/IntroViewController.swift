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
        logoLabel.text = "ChatHook"
        logoLabel.font = UIFont(name: "Avenir Medium", size:  60.0)
        logoLabel.backgroundColor = UIColor.clearColor()
        logoLabel.textColor = UIColor.whiteColor()
        logoLabel.sizeToFit()
        logoLabel.textAlignment = NSTextAlignment.Center
        logoLabel.frame.origin.x = (containerView.frame.size.width - logoLabel.frame.size.width) * half
        logoLabel.frame.origin.y = (containerView.frame.size.height - logoLabel.frame.size.height) * half
        containerView.addSubview(logoLabel)
    }//end func logoTextCenter
    
    func createLoginButtons(containerView: UIView!){
        let margin: CGFloat = 15.0
        let middleSpacing: CGFloat = 7.5
        
        let signIn = UIButton()
            signIn.setTitle("Sign In", forState: .Normal)
            signIn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            signIn.backgroundColor = UIColor.greenColor()
            signIn.frame.size.width = (((containerView.frame.size.width - signIn.frame.size.width) - (margin * 2)) / 2 - middleSpacing)
            signIn.frame.size.height = 40.0
            signIn.frame.origin.x = margin
            signIn.frame.origin.y = ((containerView.frame.size.height - signIn.frame.size.height) - 25)
            signIn.addTarget(self, action: #selector(IntroViewController.signInButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        containerView.addSubview(signIn)
        
        let register = UIButton()
            register.setTitle("Register", forState: .Normal)
            register.setTitleColor(UIColor.blackColor(), forState: .Normal)
            register.backgroundColor = UIColor.greenColor()
            register.frame.size.width = (((containerView.frame.size.width - register.frame.size.width) - (margin * 2)) / 2 - middleSpacing)
            register.frame.size.height = 40.0
            register.frame.origin.x = ((containerView.frame.size.width - register.frame.size.width) - margin)
            register.frame.origin.y = ((containerView.frame.size.height - register.frame.size.height) - 25)
            register.addTarget(self, action: #selector(IntroViewController.registerButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        containerView.addSubview(register)

    }
    
    func signInButtonPressed(sender:UIButton!){
        print("Let's Sign In")
    }
    
    func registerButtonPressed(sender:UIButton!){
        print("Let's Register")
    }

}

