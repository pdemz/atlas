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
        
        NotificationCenter.default.addObserver(self, selector: #selector(ReviewViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ReviewViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    @IBAction func starTouch(_ sender: AnyObject) {
        let selectedStar = UIImage(named: "SelectedStar")
        
        resetStars()
        
        //Set appropriate stars to filled
        if sender as! NSObject == button1{
            button1.setBackgroundImage(selectedStar, for: UIControlState())
            stars = 1
            
        }else if sender as! NSObject == button2{
            button1.setBackgroundImage(selectedStar, for: UIControlState())
            button2.setBackgroundImage(selectedStar, for: UIControlState())
            stars = 2
            
        }else if sender as! NSObject == button3{
            button1.setBackgroundImage(selectedStar, for: UIControlState())
            button2.setBackgroundImage(selectedStar, for: UIControlState())
            button3.setBackgroundImage(selectedStar, for: UIControlState())
            stars = 3
            
        }else if sender as! NSObject == button4{
            button1.setBackgroundImage(selectedStar, for: UIControlState())
            button2.setBackgroundImage(selectedStar, for: UIControlState())
            button3.setBackgroundImage(selectedStar, for: UIControlState())
            button4.setBackgroundImage(selectedStar, for: UIControlState())
            stars = 4
            
        }else if sender as! NSObject == button5{
            button1.setBackgroundImage(selectedStar, for: UIControlState())
            button2.setBackgroundImage(selectedStar, for: UIControlState())
            button3.setBackgroundImage(selectedStar, for: UIControlState())
            button4.setBackgroundImage(selectedStar, for: UIControlState())
            button5.setBackgroundImage(selectedStar, for: UIControlState())
            stars = 5
            
        }

    }
    
    //Reset all stars
    func resetStars(){
        let emptyStar = UIImage(named: "emptyStar")
        let selectedStar = UIImage(named: "SelectedStar")

        for view in starView.subviews{
            let button = view as? UIButton
            button?.setBackgroundImage(emptyStar, for: UIControlState())
        }
        
    }
    
    //Reset all stars
    func setStars(){
        let selectedStar = UIImage(named: "SelectedStar")
        
        for view in starView.subviews{
            let button = view as? UIButton
            button?.setBackgroundImage(selectedStar, for: UIControlState())
        }
        
    }
    
    func setUpCommentBox(){
        commentBox.delegate = self
        self.commentBox.layer.borderWidth = 0.5
        self.commentBox.layer.borderColor = colorHelper.blue.cgColor
        self.commentBox.layer.cornerRadius = 5
        commentBox.textColor = UIColor.lightGray
    }
    
    @IBAction func submitTap(_ sender: AnyObject) {
        //Submit the review
        var review = commentBox.text
        if commentBox.textColor == UIColor.lightGray{
            review = ""
        }
        
        YokweHelper.submitReview(stars, review: review!, revieweeID: revieweeID!, reviewType: type!)
        super.dismiss(animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxtext: Int = 140
        //If the text is larger than the maxtext, the return is false

        return textView.text.characters.count + (text.characters.count - range.length) <= maxtext        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray{
            textView.textColor = UIColor.black
            textView.text = ""
        }
    }
    
    func setUpProfilePhoto(){
        photo.image = photoImage!
        photo.layer.masksToBounds = false
        photo.layer.cornerRadius = photo.frame.height/2
        photo.clipsToBounds = true
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= commentBox.frame.minY
        }
        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y += commentBox.frame.minY
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    

}

