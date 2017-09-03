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
    
    override func viewWillAppear(_ animated: Bool) {
        //If the server returns info, then display the bank/card info and the delete button
        YokweHelper.getCardInfo { (result) in
            print("card: \(result)")
            if let cardInfo = result{
                
                DispatchQueue.main.async(execute: {
                    self.creditCard.text = cardInfo
                    self.creditCard.isHidden = false
                    
                    self.deleteCardButton.isEnabled = true
                    self.deleteCardButton.isHidden = false
                    
                    self.addCardButton.isEnabled = false
                    self.addCardButton.isHidden = true
                })
            }
            
        }
        
        YokweHelper.getBankInfo { (result) in
            print(result)
            if let bankInfo = result{
                
                DispatchQueue.main.async(execute: {
                    self.bankAccount.text = bankInfo
                    self.bankAccount.isHidden = false
                    
                    self.deleteBankButton.isEnabled = true
                    self.deleteBankButton.isHidden = false
                    
                    self.addBankButton.isEnabled = false
                    self.addBankButton.isHidden = true
                })
            }
        }

    }
    
    @IBAction func deleteCreditCard(_ sender: AnyObject) {
        
        let alertString = "If you remove your card, you won't be able to get a ride until you enter a new one"
        let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {(ACTION) in
            
            //Delete card from server
            YokweHelper.deleteCard()
            
            //Set UI
            self.setCardFieldToEmpty()
            
        })
        
        let cancelAction = UIAlertAction(title: "Never mind", style: UIAlertActionStyle.default, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func deleteBankAccount(_ sender: AnyObject) {
        
        //Pop up notificiation
        let alertString = "If you remove your bank account, we can't pay you until you add a new one"
        let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {(ACTION) in
            YokweHelper.deleteBank()
            
            self.setBankFieldToEmpty()
            
        })
        
        let cancelAction = UIAlertAction(title: "Never mind", style: UIAlertActionStyle.default, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func addCard(_ sender: AnyObject) {
        //open credit card controller
        presentPaymentForm()
        
    }
    
    @IBAction func addBank(_ sender: AnyObject) {
        //open stripe account form. Need functionality here to add payment methods to existing accounts
        presentStripeAccountForm()
        
    }
    
    func closeView(){
        
        dismiss(animated: true, completion: nil)
    }
    
    func presentPaymentForm(){
        var vc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentForm") as! PaymentFormViewController
        vc = UIHelper.customizeVC(vc) as! PaymentFormViewController
        vc.title = "Payment Info"
        
        var navController = UINavigationController(rootViewController: vc)
        navController = UIHelper.customizeNavController(navController)
        
        present(navController, animated: true, completion: nil)
    }
    
    func presentStripeAccountForm(){
        var vc = self.storyboard?.instantiateViewController(withIdentifier: "DriverAccountCreation") as! DriverAccountCreationViewController
        vc = UIHelper.customizeVC(vc) as! DriverAccountCreationViewController
        vc.title = "Create driver account"
        
        var navController = UINavigationController(rootViewController: vc)
        navController = UIHelper.customizeNavController(navController)
        
        navController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        present(navController, animated: true, completion: nil)
    }
    
    func setCardFieldToEmpty(){
        deleteCardButton.isEnabled = false
        deleteCardButton.isHidden = true
        
        creditCard.isHidden = true
        
        addCardButton.isHidden = false
        addCardButton.isEnabled = true
    }
    
    func setBankFieldToEmpty(){
        deleteBankButton.isEnabled = false
        deleteBankButton.isHidden = true
        
        bankAccount.isHidden = true
        
        addBankButton.isHidden = false
        addBankButton.isEnabled = true
    }
    
}
