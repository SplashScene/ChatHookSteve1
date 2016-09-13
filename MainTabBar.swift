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
    var introViewController = IntroViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        //set up our custom view controllers
        
        
        let mapViewController = GetLocation1()
        let messagesViewController = MessagesController()
        let postsViewController = RoomsViewController()
        let chatNavController = UINavigationController(rootViewController: messagesViewController)
        let postsNavController = UINavigationController(rootViewController: postsViewController)
        let profileViewController = ProfileViewController()
        
        mapViewController.title = "Home"
        mapViewController.tabBarItem.image = UIImage(named: "GlobeIcon25")
        
        messagesViewController.title = "Chat"
        messagesViewController.tabBarItem.image = UIImage(named: "ChatIcon25")
        
        postsViewController.title = "Posts"
        postsViewController.tabBarItem.image = UIImage(named: "peeps")
        
        profileViewController.title = "Profile"
        profileViewController.tabBarItem.image = UIImage(named: "ProfileIcon25")
        
        
        viewControllers = [mapViewController, chatNavController, postsNavController, profileViewController]
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBar.barTintColor = UIColor.whiteColor()
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
