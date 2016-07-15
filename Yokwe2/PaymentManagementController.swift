//
//  PaymentManagementController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 7/6/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

class PaymentManagementController: UITableViewController {
    
    @IBOutlet weak var deleteBankButton: UIButton!
    @IBOutlet weak var deleteCardButton: UIButton!
    @IBOutlet weak var addBankButton: UIButton!
    @IBOutlet weak var addCardButton: UIButton!
    
    @IBOutlet weak var creditCard: UILabel!
    @IBOutlet weak var bankAccount: UILabel!
    
    @IBOutlet var mainTableView: UITableView!
    
    override func viewDidLoad() {
        self.title = "Cards & Banks"
        mainTableView.tableFooterView = UIView()
        
        creditCard.adjustsFontSizeToFitWidth = true
        bankAccount.adjustsFontSizeToFitWidth = true
        
        //By default, set card and bank fields to empty and display add button
        setCardFieldToEmpty()
        setBankFieldToEmpty()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        //If the server returns info, then display the bank/card info and the delete button
        YokweHelper.getCardInfo { (result) in
            print("card: \(result)")
            if let cardInfo = result{
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.creditCard.text = cardInfo
                    self.creditCard.hidden = false
                    
                    self.deleteCardButton.enabled = true
                    self.deleteCardButton.hidden = false
                    
                    self.addCardButton.enabled = false
                    self.addCardButton.hidden = true
                })
            }
            
        }
        
        YokweHelper.getBankInfo { (result) in
            print(result)
            if let bankInfo = result{
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.bankAccount.text = bankInfo
                    self.bankAccount.hidden = false
                    
                    self.deleteBankButton.enabled = true
                    self.deleteBankButton.hidden = false
                    
                    self.addBankButton.enabled = false
                    self.addBankButton.hidden = true
                })
            }
        }

    }
    
    @IBAction func deleteCreditCard(sender: AnyObject) {
        
        let alertString = "If you remove your card, you won't be able to get a ride until you enter a new one"
        let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {(ACTION) in
            
            //Delete card from server
            YokweHelper.deleteCard()
            
            //Set UI
            self.setCardFieldToEmpty()
            
        })
        
        let cancelAction = UIAlertAction(title: "Never mind", style: UIAlertActionStyle.Default, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func deleteBankAccount(sender: AnyObject) {
        
        //Pop up notificiation
        let alertString = "If you remove your bank account, we can't pay you until you add a new one"
        let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {(ACTION) in
            YokweHelper.deleteBank()
            
            self.setBankFieldToEmpty()
            
        })
        
        let cancelAction = UIAlertAction(title: "Never mind", style: UIAlertActionStyle.Default, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func addCard(sender: AnyObject) {
        //open credit card controller
        presentPaymentForm()
        
    }
    
    @IBAction func addBank(sender: AnyObject) {
        //open bank account controller
        presentBankForm()
        
    }
    
    func closeView(){
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func presentPaymentForm(){
        var vc = self.storyboard?.instantiateViewControllerWithIdentifier("PaymentForm") as! PaymentFormViewController
        vc = UIHelper.customizeVC(vc) as! PaymentFormViewController
        vc.title = "Payment Info"
        
        var navController = UINavigationController(rootViewController: vc)
        navController = UIHelper.customizeNavController(navController)
        
        presentViewController(navController, animated: true, completion: nil)
    }
    
    func presentBankForm(){
        var vc = self.storyboard?.instantiateViewControllerWithIdentifier("BankAccountCreation") as! BankAccountCreation
        vc = UIHelper.customizeVC(vc) as! BankAccountCreation
        vc.title = "Payment Info"
        
        var navController = UINavigationController(rootViewController: vc)
        navController = UIHelper.customizeNavController(navController)
        
        navController.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        presentViewController(navController, animated: true, completion: nil)
    }
    
    func setCardFieldToEmpty(){
        deleteCardButton.enabled = false
        deleteCardButton.hidden = true
        
        creditCard.hidden = true
        
        addCardButton.hidden = false
        addCardButton.enabled = true
    }
    
    func setBankFieldToEmpty(){
        deleteBankButton.enabled = false
        deleteBankButton.hidden = true
        
        bankAccount.hidden = true
        
        addBankButton.hidden = false
        addBankButton.enabled = true
    }
    
}
