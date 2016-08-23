//
//  MainTabBar.swift
//  ChatHook
//
//  Created by Kevin Farm on 8/22/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit

class MainTabBar: UITabBarController {
    
    var registerViewController = FinishRegisterController()

    override func viewDidLoad() {
        super.viewDidLoad()
        //set up our custom view controllers
        
        
        let mapViewController = GetLocation1()
        let messagesViewController = MessagesController()
        let chatNavController = UINavigationController(rootViewController: messagesViewController)
        
        mapViewController.title = "Home"
        mapViewController.tabBarItem.image = UIImage(named: "GlobeIcon25")
        messagesViewController.title = "Chat"
        messagesViewController.tabBarItem.image = UIImage(named: "ChatIcon25")
        
        viewControllers = [mapViewController, chatNavController]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
