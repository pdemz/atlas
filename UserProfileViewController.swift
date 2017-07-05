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
        aboutMe.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        
        aboutMe.layer.borderWidth = 1
        aboutMe.layer.cornerRadius = 4
        aboutMe.keyboardType  = .asciiCapable
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(UserProfileViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UserProfileViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func editProfile(){
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(UserProfileViewController.finishedEditing))
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.leftBarButtonItem = nil
        
        if aboutMeText == nil || aboutMeText == ""{
            aboutMe.textColor = UIColor.lightGray
            aboutMe.text = "Express yo self..."
        }
        
        aboutMe.isEditable = true
        aboutMe.bounces = true
        //aboutMe.firstRespo
    }
    
    func closeView(){
        //Only make request if text changed
        if aboutMe.text != aboutMeText{
            YokweHelper.storeUser()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func finishedEditing(){
        let editButton = UIBarButtonItem(image: UIImage(named: "Pencil"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(UserProfileViewController.editProfile))
        self.navigationItem.rightBarButtonItem = editButton
        
        let dismissButton = UIBarButtonItem(image: UIImage(named: "Close"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(UserProfileViewController.closeView))
        self.navigationItem.leftBarButtonItem = dismissButton
        
        if aboutMe.textColor == UIColor.lightGray{
            aboutMe.text = nil
        }
        
        SharingCenter.sharedInstance.aboutMe = aboutMe.text
        
        aboutMe.isEditable = false
        aboutMe.bounces = false
        
    }
    
    @IBAction func tappedNumber(_ sender: AnyObject) {
        if phoneText != nil && phoneText != ""{
            let number = phoneText!.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ") ", with: "").replacingOccurrences(of: "-", with: "")
            let url = "sms:\(number)"
            UIApplication.shared.openURL(URL(string: url)!)
            
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray{
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    
    func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= keyboardSize.height
        }
        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLength = 140
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
}


