//
//  SettingsViewController.swift
//  DojStagram
//
//  Created by Daniel Thompson on 3/29/17.
//  Copyright © 2017 Daniel Thompson. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let isUserLoggedIn =  UserDefaults.standard.bool(forKey: "userLoggedIn")
        
        if(!isUserLoggedIn){
            if let loginController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginPageViewController {
                self.present(loginController, animated: true, completion: nil)
            }
        } else {
            // check if API token has expired
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let userTokenExpiryDate: String? = KeychainAccess.passwordForAccount(account: "Auth_Token_Expiry", service: "KeyChainService")
            
            let dateFromString: Date? = dateFormatter.date(from: userTokenExpiryDate!)
            let now = Date()
            
            let comparison = now.compare(dateFromString!)
            
            if comparison != ComparisonResult.orderedAscending {
                self.logoutPressed(nil)
            }
        }

        
    }
    
    
    @IBAction func logoutPressed(_ sender: UIButton?) {
        
        clearLoggedinFlag()
        clearAPITokensFromKeyChain()
        
        self.viewDidAppear(true)
        
    }
    
    func clearLoggedinFlag(){
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "userLoggedIn")
        defaults.synchronize()
    }
    
    func clearAPITokensFromKeyChain(){
        if let userToken = KeychainAccess.passwordForAccount(account: "Auth_Token", service: "KeyChainService") {
            KeychainAccess.deletePasswordForAccount(password: userToken, account: "Auth_Token", service: "KeyChainService")
        }
        
        if let userTokenExpiryDate = KeychainAccess.passwordForAccount(account: "Auth_Token_Expiry", service: "KeyChainService") {
            KeychainAccess.deletePasswordForAccount(password: userTokenExpiryDate, account: "Auth_Token_Expiry", service: "KeyChainService")
        }
    }
    
    

}
