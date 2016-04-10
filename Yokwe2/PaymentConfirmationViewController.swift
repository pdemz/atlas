//
//  PaymentConfirmationViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 3/21/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import UIKit
import Stripe

class PaymentConfirmationViewController: UIViewController {

    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var cardNum: UILabel!
    @IBOutlet weak var expDate: UILabel!
    @IBOutlet weak var cvc: UILabel!
    
    var nameText:String?
    var emailText:String?
    var card:STPCardParams?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        email.text = emailText!
        cardNum.text = card!.number!
        expDate.text = "\(card!.expMonth)\(card!.expYear)"
        cvc.text = card!.cvc!
        
    }

    @IBAction func save(sender: AnyObject) {
        


    }

}
