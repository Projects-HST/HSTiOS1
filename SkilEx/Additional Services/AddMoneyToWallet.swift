//
//  AddMoneyToWallet.swift
//  SkilEx
//
//  Created by Happy Sanz Tech on 29/04/20.
//  Copyright © 2020 Happy Sanz Tech. All rights reserved.
//

import UIKit

class AddMoneyToWallet: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var addMoneyToLabel: UILabel!
    @IBOutlet weak var skilexWalletLabel: UILabel!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var proceedOutlet: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        amount.delegate = self
        self.addToolBar(textField: amount)
        view.bindToKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.preferedLanguage()
        self.addBackButton()
        proceedOutlet.addShadowToButton(color: UIColor.gray, cornerRadius: self.proceedOutlet.frame.height / 2, backgroundcolor: UIColor(red: 19.0/255, green: 90.0/255, blue: 160.0/255, alpha: 1.0))
    }
    
    func preferedLanguage()
    {
        self.navigationItem.title =  LocalizationSystem.sharedInstance.localizedStringForKey(key: "SkilexWalletnavtitle_text", comment: "")
    }
    
    @objc public override func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func generateRandomDigits(_ digitNumber: Int) -> String {
        var number = ""
        for i in 0..<digitNumber {
            var randomNumber = arc4random_uniform(10)
            while randomNumber == 0 && i == 0 {
                randomNumber = arc4random_uniform(10)
            }
            number += "\(randomNumber)"
        }
        return number
    }
    
    func addToWalletByPaymemtGateway (amount:String)
    {
        let randomNumbers = Int(generateRandomDigits(5))
        print(randomNumbers!)
        
        let concordinateString = "\(String(describing: randomNumbers))" + "-" + GlobalVariables.shared.user_master_id
        UserDefaults.standard.set("MW", forKey: "Advance/customer")
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "CCWebViewController") as! CCWebViewController
        viewController.accessCode = "AVQM86GG76CA98MQAC"
        viewController.merchantId = "225068"
        viewController.amount = amount
        // advance_amount
        viewController.strAddMoneyToWallet = concordinateString
        viewController.currency = "INR"
        viewController.orderId = concordinateString
        viewController.redirectUrl = String(format: "%@%@", AFWrapper.PaymentBaseUrl,"ccavenue_app/customer_advance.php")
        viewController.cancelUrl = String(format: "%@%@", AFWrapper.PaymentBaseUrl,"customer_advance.php")
        viewController.rsaKeyUrl = String(format: "%@%@", AFWrapper.PaymentBaseUrl,"ccavenue_app/GetRSA.php")
                
        self.present(viewController, animated: true, completion: nil)

    }
    
    @IBAction func proceedAction(_ sender: Any)
    {
        if amount.text!.isEmpty
        {
            Alert.defaultManager.showOkAlert(LocalizationSystem.sharedInstance.localizedStringForKey(key: "appname_text", comment: ""), message: "Enter Amount") { (action) in
                //Custom action code
            }
        }
        else
        {
            self.addToWalletByPaymemtGateway(amount: self.amount.text!)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
