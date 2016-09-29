//
//  ReviewViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 5/25/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var starView: UIView!
    @IBOutlet weak var commentBox: UITextView!
    
    var photoImage:UIImage?
    var stars = 5
    var revieweeID:String?
    var type:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStars()
        setUpCommentBox()
        setUpProfilePhoto()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ReviewViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ReviewViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    @IBAction func starTouch(sender: AnyObject) {
        let selectedStar = UIImage(named: "SelectedStar")
        
        resetStars()
        
        //Set appropriate stars to filled
        if sender as! NSObject == button1{
            button1.setBackgroundImage(selectedStar, forState: .Normal)
            stars = 1
            
        }else if sender as! NSObject == button2{
            button1.setBackgroundImage(selectedStar, forState: .Normal)
            button2.setBackgroundImage(selectedStar, forState: .Normal)
            stars = 2
            
        }else if sender as! NSObject == button3{
            button1.setBackgroundImage(selectedStar, forState: .Normal)
            button2.setBackgroundImage(selectedStar, forState: .Normal)
            button3.setBackgroundImage(selectedStar, forState: .Normal)
            stars = 3
            
        }else if sender as! NSObject == button4{
            button1.setBackgroundImage(selectedStar, forState: .Normal)
            button2.setBackgroundImage(selectedStar, forState: .Normal)
            button3.setBackgroundImage(selectedStar, forState: .Normal)
            button4.setBackgroundImage(selectedStar, forState: .Normal)
            stars = 4
            
        }else if sender as! NSObject == button5{
            button1.setBackgroundImage(selectedStar, forState: .Normal)
            button2.setBackgroundImage(selectedStar, forState: .Normal)
            button3.setBackgroundImage(selectedStar, forState: .Normal)
            button4.setBackgroundImage(selectedStar, forState: .Normal)
            button5.setBackgroundImage(selectedStar, forState: .Normal)
            stars = 5
            
        }

    }
    
    //Reset all stars
    func resetStars(){
        let emptyStar = UIImage(named: "emptyStar")
        let selectedStar = UIImage(named: "SelectedStar")

        for view in starView.subviews{
            let button = view as? UIButton
            button?.setBackgroundImage(emptyStar, forState: .Normal)
        }
        
    }
    
    //Reset all stars
    func setStars(){
        let selectedStar = UIImage(named: "SelectedStar")
        
        for view in starView.subviews{
            let button = view as? UIButton
            button?.setBackgroundImage(selectedStar, forState: .Normal)
        }
        
    }
    
    func setUpCommentBox(){
        commentBox.delegate = self
        self.commentBox.layer.borderWidth = 0.5
        self.commentBox.layer.borderColor = colorHelper.blue.CGColor
        self.commentBox.layer.cornerRadius = 5
        commentBox.textColor = UIColor.lightGrayColor()
    }
    
    @IBAction func submitTap(sender: AnyObject) {
        //Submit the review
        var review = commentBox.text
        if commentBox.textColor == UIColor.lightGrayColor(){
            review = ""
        }
        
        YokweHelper.submitReview(stars, review: review, revieweeID: revieweeID!, reviewType: type!)
        super.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let maxtext: Int = 140
        //If the text is larger than the maxtext, the return is false

        return textView.text.characters.count + (text.characters.count - range.length) <= maxtext        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor(){
            textView.textColor = UIColor.blackColor()
            textView.text = ""
        }
    }
    
    func setUpProfilePhoto(){
        photo.image = photoImage!
        photo.layer.masksToBounds = false
        photo.layer.cornerRadius = photo.frame.height/2
        photo.clipsToBounds = true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= commentBox.frame.minY
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += commentBox.frame.minY
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    

}

