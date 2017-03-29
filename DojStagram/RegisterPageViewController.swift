//
//  RegisterPageViewController.swift
//  LoginRegistration
//
//  Created by Daniel Thompson on 3/21/17.
//  Copyright © 2017 Daniel Thompson. All rights reserved.
//

import UIKit

class RegisterPageViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    let httpHelper = HTTPHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func alreadyHaveAccountButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        
        let userName = userNameTextField.text
        let userEmail = userEmailTextField.text
        let userPassword = userPasswordTextField.text
        let repeatPassword = repeatPasswordTextField.text
        
        // Check for empty fields
        if((userEmail?.isEmpty)! || (userPassword?.isEmpty)! || (repeatPassword?.isEmpty)! || (userName?.isEmpty)!) {
            
            // display alert message
            displayErrorAlertMessage(alertTitle: "Error DX", alertMessage: "All fields are required")
            
            return
        }
        
        // check if passwords match
        if(userPassword != repeatPassword) {
            
            // display alert message
            displayErrorAlertMessage(alertMessage: "Passwords do not match")
            return
            
        }
        
        makeSignUpRequest(userName: userName!, userEmail: userEmail!, userPassword: userPassword!)
        
    }
    
    
    
    func makeSignUpRequest(userName: String, userEmail: String, userPassword: String) {
        
        // create HTTP request and set request header
        var httpRequest = httpHelper.buildRequest(path: "signup", method: "POST", authType: HTTPRequestAuthType.HTTPBasicAuth)
        
        // encrypt password with the API key

        let encrypted_password = AESCrypt.encrypt(userPassword, password: HTTPHelper.API_AUTH_PASSWORD)
        // Set the request body
        httpRequest.httpBody = "{\"full_name\":\"\(userName)\",\"email\":\"\(userEmail)\",\"password\":\"\(encrypted_password!)\"}".data(using: String.Encoding.utf8)
        
        // Send the request
        httpHelper.sendRequest(request: httpRequest){
            (data:Data?, error:Error?) in
            
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error: error!)
                self.displayErrorAlertMessage(alertTitle: "Error DX", alertMessage: errorMessage as String)
                
                return
            }
            
            let completionHandler = {
                print(self)
                self.dismiss(animated: true, completion: nil)
            }
            
            // find some way to verify that the account was actually created
            
            print(data)
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                print(jsonResponse)
            } catch let jsonParsingError {
                print(jsonParsingError.localizedDescription)
            }
            
            self.displayErrorAlertMessage(alertTitle: "Success", completion: completionHandler, alertMessage: "Account has been created")
        }
        
        
    }
    
    

    func displayErrorAlertMessage(alertTitle:String = "Error DX", completion: (() -> Void)? = nil, alertMessage:String){
        let myAlert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }

}
