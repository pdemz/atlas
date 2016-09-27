//
//  ContentViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 8/14/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import UIKit

class TutorialContentViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var pageIndex: Int!
    var titleText: String!
    var imageFile: String!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.imageView.image = UIImage(named: self.imageFile)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

