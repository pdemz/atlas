//
//  ViewController.swift
//  UIPageViewController
//
//  Created by PJ Vea on 3/27/15.
//  Copyright (c) 2015 Vea Software. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UIPageViewControllerDataSource {
    
    var pageViewController: UIPageViewController!
    var pageTitles: NSArray!
    var pageImages: NSArray!
    
    var currentIndex:Int?
    var pendingIndex:Int?
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var restartButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.pageTitles = NSArray(objects: "Explore", "Today Widget", "Demz", "Guy", "Dude")
        self.pageImages = NSArray(objects: "Tutorial1", "Tutorial2", "Tutorial3", "Tutorial4", "Tutorial5")
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialPageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        
        let startVC = self.viewControllerAtIndex(0) as TutorialContentViewController
        let viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as! [UIViewController], direction: .Forward, animated: true, completion: nil)
        
        self.pageViewController.view.frame = CGRectMake(0, 20, self.view.frame.width, self.view.frame.size.height - 60)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
        // Configure our custom pageControl
        view.bringSubviewToFront(pageControl)
        pageControl.numberOfPages = 5
        pageControl.currentPage = 0
        
        
        restartButton.enabled = false
        restartButton.alpha = 0.4
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //What happens when you tap finish
    @IBAction func restartAction(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        /*
        var startVC = self.viewControllerAtIndex(0) as TutorialContentViewController
        var viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as! [UIViewController], direction: .Forward, animated: true, completion: nil)
         
         */
    }
    
    func viewControllerAtIndex(index: Int) -> TutorialContentViewController
    {
        if ((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
            return TutorialContentViewController()
        }
        
        let vc: TutorialContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialContentViewController") as! TutorialContentViewController
        
        vc.imageFile = self.pageImages[index] as! String
        vc.titleText = self.pageTitles[index] as! String
        vc.pageIndex = index
        //pageControl.currentPage = index
        
        return vc
        
    }
    
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        
        let vc = viewController as! TutorialContentViewController
        var index = vc.pageIndex as Int
        
        if (index == 0 || index == NSNotFound)
        {
            return nil
            
        }
        pageControl.currentPage = index
        
        index -= 1
        return self.viewControllerAtIndex(index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! TutorialContentViewController
        var index = vc.pageIndex as Int
        
        if index == 4{
            restartButton.enabled = true
            restartButton.alpha = 1
        }
        pageControl.currentPage = index
        
        if (index == NSNotFound)
        {
            return nil
        }
        
        index += 1
        
        if (index == self.pageTitles.count)
        {
            return nil
        }
        
        return self.viewControllerAtIndex(index)
        
    }
    
    
    
    /*
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 0
    }
    */
}

