//
//  HomeTableTableViewController.swift
//  DojStagram
//
//  Created by Daniel Thompson on 3/30/17.
//  Copyright © 2017 Daniel Thompson. All rights reserved.
//

import UIKit
import CoreData

class HomeTableTableViewController: UITableViewController {
    
    let httpHelper = HTTPHelper()
    
    var postData = [GalleryPost]()
    var shouldFetchNewData = true
    
//    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let isUserLoggedIn =  UserDefaults.standard.bool(forKey: "userLoggedIn")
        
        if(!isUserLoggedIn){
            print("user not logged in")
            if let loginController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginPageViewController {
                self.tabBarController?.present(loginController, animated: true, completion: nil)
            }
        } else {
            // check if API token has expired
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let userTokenExpiryDate: String? = KeychainAccess.passwordForAccount(account: "Auth_Token_Expiry", service: "KeyChainService")
            
            print("token expiry date: \(userTokenExpiryDate ?? "None")")
            
            let dateFromString: Date? = dateFormatter.date(from: userTokenExpiryDate!)
            let now = Date()
            
            let comparison = now.compare(dateFromString!)
            
            if shouldFetchNewData {
                getHomeFeedPosts()
                shouldFetchNewData = false
            }
            
            if comparison != ComparisonResult.orderedAscending {
                //self.logoutBtnTapped()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return postData.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostViewCell") as! PostViewCell
        
        let cellPostData = postData[indexPath.row]
        
        if let filePathString = cellPostData.serverURL {
            
            let imgURL: URL = URL(string: filePathString)!
            
            let request = URLRequest(url: imgURL)
            
            let task = URLSession.shared.dataTask(with: request){(data:Data?, response:URLResponse?, error: Error?) -> Void in
                if error != nil {
                    print("Get image error: \(String(describing: error?.localizedDescription))")
                } else {
                    if data != nil {
                        let image = UIImage(data: data!)
                        DispatchQueue.main.async{
                            cell.postImageView?.image = image
                        }
                    }
                }
            }
            task.resume()
        }

        cell.captionLabel.text = cellPostData.caption
//        cell.locationLabel.text = cellPostData.location
//        cell.dateLabel.text = cellPostData.createdAt
//        cell.likesLabel.text = cellPostData.likes
        
        return cell
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
                    
                    if jsonResponseDictionary != nil {
                        
                        for photoData in jsonResponseDictionary! {
                            
                            if let photoDataDict = photoData as? [String:AnyObject] {
                                
//                                let newPhoto = Photo(context: self.moc)
                                let newPost = GalleryPost()
                                
                                if let filePathString = photoDataDict["image_url"] as? String {
                                    newPost.serverURL = filePathString
                                }
                                
                                if let nameString = photoDataDict["title"] as? String {
                                    newPost.caption = nameString
                                }
                                
                                if let user_id_int = photoDataDict["user_id"] as? Int64 {
                                    newPost.user_id = user_id_int
                                }
                                
                                DispatchQueue.main.async {
                                    self.postData.append(newPost)
                                    self.tableView.reloadData()
                                    print("total posts: \(self.postData.count)")
                                }
                                
                                
                            }
                            
                        }
                        
                    }
                    
                    
                    
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
