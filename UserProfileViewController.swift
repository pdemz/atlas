//
//  DriverProfile.swift
//  
//
//  Created by Pierce Demarreau on 11/3/15.
//
//

import UIKit
import FBSDKCoreKit

class UserProfileViewController: UIViewController, UITextViewDelegate {
    
    var photoImage:UIImage? = nil
    var aboutMeText:String?
    var phoneText:String?
    var educationText:String?
    var locationText:String?
    
    @IBOutlet weak var aboutMe: UITextView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var education: UILabel!
    @IBOutlet weak var phoneButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = photoImage
        photo.layer.masksToBounds = false
        photo.layer.cornerRadius = 5
        photo.clipsToBounds = true
        
        aboutMe.delegate = self
        aboutMe.text = aboutMeText
        aboutMe.layer.borderColor = UIColor.groupTableViewBackgroundColor().CGColor
        
        aboutMe.layer.borderWidth = 1
        aboutMe.layer.cornerRadius = 4
        aboutMe.keyboardType  = .ASCIICapable
        
        if phoneText != nil{
            phone.text = phoneText

        }else{
            phone.text = "Not available until trip starts"
            
        }
        phone.adjustsFontSizeToFitWidth = true
        
        education.text = educationText
        education.adjustsFontSizeToFitWidth = true
        
        if locationText != nil{
            location.text = locationText

        }
        
        /*
        friendIcon.image = friendIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        friendIcon.tintColor = colorHelper.orange
        
        friendIcon.hidden = friendIconHidden
        */
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func editProfile(){
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "finishedEditing")
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.leftBarButtonItem = nil
        
        if aboutMeText == nil || aboutMeText == ""{
            aboutMe.textColor = UIColor.lightGrayColor()
            aboutMe.text = "Express yo self..."
        }
        
        aboutMe.editable = true
        aboutMe.bounces = true
        //aboutMe.firstRespo
    }
    
    func closeView(){
        //Only make request if text changed
        if aboutMe.text != aboutMeText{
            YokweHelper.storeUser()
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func finishedEditing(){
        let editButton = UIBarButtonItem(image: UIImage(named: "Pencil"), style: UIBarButtonItemStyle.Plain, target: self, action: "editProfile")
        self.navigationItem.rightBarButtonItem = editButton
        
        let dismissButton = UIBarButtonItem(image: UIImage(named: "Close"), style: UIBarButtonItemStyle.Plain, target: self, action: "closeView")
        self.navigationItem.leftBarButtonItem = dismissButton
        
        if aboutMe.textColor == UIColor.lightGrayColor(){
            aboutMe.text = nil
        }
        
        SharingCenter.sharedInstance.aboutMe = aboutMe.text
        
        aboutMe.editable = false
        aboutMe.bounces = false
        
    }
    
    @IBAction func tappedNumber(sender: AnyObject) {
        if phoneText != nil && phoneText != ""{
            let number = phoneText!.stringByReplacingOccurrencesOfString("(", withString: "").stringByReplacingOccurrencesOfString(") ", withString: "").stringByReplacingOccurrencesOfString("-", withString: "")
            let url = "sms:\(number)"
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
            
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor(){
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLength = 140
        let currentString: NSString = textField.text!
        let newString: NSString =
            currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxLength
    }
    
}


