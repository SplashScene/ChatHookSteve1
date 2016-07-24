//
//  TutorialPageViewController.swift
//  ChatHook
//
//  Created by Kevin Farm on 7/19/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit

private(set) var orderedViewControllers: [UIViewController] = {
    return [newTutorialViewController("Tutorial1"),
            newTutorialViewController("Tutorial2"),
            newTutorialViewController("Tutorial3")]
}()

private func newTutorialViewController(tutorial: String) -> UIViewController{
    return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("\(tutorial)")
    
}

class TutorialPageViewController: UIPageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first{
            setViewControllers([firstViewController],
                               direction: .Forward,
                               animated: true,
                               completion: nil)
        }
    }

    @IBAction func doneButtonTapped(sender: AnyObject) {
        let nextView:CurrentLocationViewcontrollerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CurrentLocationViewController") as! CurrentLocationViewcontrollerViewController
        
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appdelegate.window!.rootViewController = nextView
    }
}

extension TutorialPageViewController: UIPageViewControllerDataSource{
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        
        guard orderedViewControllers.count > previousIndex else { return nil }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else { return nil }
        
        guard orderedViewControllersCount > nextIndex else { return nil }
        
        return orderedViewControllers[nextIndex]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first, firstViewControllerIndex = orderedViewControllers.indexOf(firstViewController) else { return 0 }
        return firstViewControllerIndex
    }
    
    
}
