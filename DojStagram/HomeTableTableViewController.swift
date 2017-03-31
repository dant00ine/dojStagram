//
//  HomeTableTableViewController.swift
//  DojStagram
//
//  Created by Daniel Thompson on 3/30/17.
//  Copyright © 2017 Daniel Thompson. All rights reserved.
//

import UIKit

class HomeTableTableViewController: UITableViewController {
    
    let httpHelper = HTTPHelper()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        getHomeFeedPosts()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }
    
    
    
    
    func getHomeFeedPosts(){
        
        let homePostsRequest = httpHelper.buildRequest(path: "start_home_feed", method: "GET", authType: HTTPRequestAuthType.HTTPTokenAuth)
        print(homePostsRequest)

        httpHelper.sendRequest(request: homePostsRequest, completion: {(data, error)in
            
            if error != nil {
                
                self.displayErrorAlertMessage(alertMessage: String(describing: error))
                
            }
            
            if data != nil {
                do {
                    let jsonResponseDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray
                    
                    print(jsonResponseDictionary ?? "No response dict")
                    
                } catch let requestError {
                    print("request error: \(requestError.localizedDescription)")
                }
            }
            
        
        })
        
    }
    
    
    
    
    func displayErrorAlertMessage(alertTitle:String = "Error DX", completion: (() -> Void)? = nil, alertMessage:String){
        let myAlert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }
    
}
