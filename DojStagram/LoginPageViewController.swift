//
//  LoginPageViewController.swift
//  LoginRegistration
//
//  Created by Daniel Thompson on 3/21/17.
//  Copyright © 2017 Daniel Thompson. All rights reserved.
//

import UIKit

class LoginPageViewController: UIViewController {
    @IBAction func unwindToLoginView(segue:UIStoryboardSegue) {
    }
    

    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    let httpHelper = HTTPHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func noAccountButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "registerInstead", sender: nil)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        let userEmail = userEmailTextField.text
        let userPassword = userPasswordTextField.text
        
        if (userEmail?.isEmpty)! && (userPassword?.isEmpty)! {
           
            self.displayErrorAlertMessage(alertMessage: "You didn't type anything in lol XD")
            
        } else {
            
            makeSignInRequest(userEmail: userEmail!, userPassword: userPassword!)
            
        }
        
    }
    
    
    
    func makeSignInRequest(userEmail:String, userPassword:String){
        
        // Create HTTP request and set request Body
        var httpRequest = httpHelper.buildRequest(path: "signin", method: "POST", authType: HTTPRequestAuthType.HTTPBasicAuth)

        let encrypted_password = AESCrypt.encrypt(userPassword, password: HTTPHelper.API_AUTH_PASSWORD)!
        
        httpRequest.httpBody = "{\"email\":\"\(userEmail)\",\"password\":\"\(encrypted_password)\"}".data(using: String.Encoding.utf8)
        
        httpHelper.sendRequest(request: httpRequest){ (data:Data?, error:Error?) in
            
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error: error!)
                self.displayErrorAlertMessage(alertMessage: errorMessage as String)
                
                return
            }
            
            do {
                let responseDict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                
                self.saveApiTokenInKeychain(tokenDict: responseDict)
                
                self.updateUserLoggedInFlag()
                
            } catch let jsonParseError {
                print(jsonParseError.localizedDescription)
            }
            
        }
        
    }
    
    
    
    func updateUserLoggedInFlag(){
        print("user logged in flag updated")
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "userLoggedIn")
        defaults.synchronize()
    }
    
    
    
    func saveApiTokenInKeychain(tokenDict: NSDictionary){
        
        tokenDict.enumerateKeysAndObjects({
            dictKey, dictVal, stopBool in
            
            let myKey = dictKey as! String
            let myVal = dictVal as! String
            
            if myKey == "api_authtoken" {
                KeychainAccess.setPassword(password: myVal, account: "Auth_Token", service: "KeyChainService")
            }
            
            if myKey == "authtoken_expiry" {
                KeychainAccess.setPassword(password: myVal, account: "Auth_Token_Expiry", service: "KeyChainService")
            }
        })
        
        self.dismiss(animated: true, completion: nil)

    }
    
    
    
    func displayErrorAlertMessage(alertTitle:String = "Error DX", completion: (() -> Void)? = nil, alertMessage:String){
        let myAlert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
        

    }

}
