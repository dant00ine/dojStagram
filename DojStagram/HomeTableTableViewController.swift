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
        
        
        
    }
    
}
