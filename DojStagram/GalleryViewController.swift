//
//  GalleryViewController.swift
//  DojStagram
//
//  Created by Paul Binneboese on 3/23/17.
//  Copyright © 2017 Daniel Thompson. All rights reserved.
//

import UIKit
import CoreData

// photos from the server
class GalleryImage {
    var imageTitle : String!        // caption
    var imageThumbnailURL : String! // URL to thumbnail image
    var imageId : String!           // unique ID for entry
    var thumbLocalImage : UIImage!  // image as thumbnail
}

// cached photos in CoreData look like this:
//class Photo {
//    var image: UIImage!
//    var filepath: String!
//    var caption: String!
//    var location: String!
//    var createdAt: Date!
//    var likes: Int!
//}

// Posts (from either source
class GalleryPost {
    var imageThumbnailURL : String! // URL to thumbnail image
    var imageId : String!           // unique ID for entry
    var thumbLocalImage : UIImage!  // image as thumbnail
    var caption: String!
    var username: String!
    var location: String!
    var createdAt: Date!
    var likes: Int!
}

private let reuseIdentifier = "PhotoViewCell"

class GalleryViewController: UIViewController, UIToolbarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var shouldFetchNewData = true
    var GalleryImages = [GalleryImage]()    // photos stored on server
    var Photos = [Photo]()  // photos stored in CoreData
    var GalleryPosts = [GalleryPost]()  // all posts (from server and CoreData)
    
    
    let httpHelper = HTTPHelper()

    @IBOutlet weak var collectionView: UICollectionView!
    
    // View Controller Stuff
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        // Register cell classes - not needed
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
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
            if comparison != ComparisonResult.orderedAscending {
                //self.logoutBtnTapped()
            }
        }

        // fetch posts stored locally
        fetchPhotosFromDB()
        // fetch posts from the server
        if shouldFetchNewData {
            shouldFetchNewData = false
            //self.setNavigationItems()
            loadPhotoData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // segue to Post View
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let PostView = segue.destination as! PostViewController
        PostView.delegate = self
        if segue.identifier == "PostViewSegue" {   // show post
            let indexPath = sender as! NSIndexPath
            PostView.photo = Photos[indexPath.row]
        }
    }

    
    // Fetch the user's posts from the server
    func loadPhotoData(){
        let httpRequest = httpHelper.buildRequest(path: "get_user_photos", method: "GET", authType: HTTPRequestAuthType.HTTPTokenAuth)
        
        httpHelper.sendRequest(request: httpRequest, completion: {(data:Data?, error:Error?) in
            
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error: error!)
                // needs to be made into UIAlertController
                let errorAlert = UIAlertView(title: "Error", message: errorMessage, delegate: nil, cancelButtonTitle: "OK")
                errorAlert.show()
                return
            }
            do {
                if let jsonPosts = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Array<Any> {
                    
                    for imageData in jsonPosts {
                        if let imageDataDict = imageData as? NSDictionary {
                            let photoImage = GalleryImage()
                            
                            photoImage.imageTitle = imageDataDict.value(forKey:"title") as! String
                            photoImage.imageId = imageDataDict.value(forKey:"random_id") as! String
                            photoImage.imageThumbnailURL = imageDataDict.value(forKey:"image_url") as! String

                            // get thumbnail image
                            let imgURL: URL = URL(string: photoImage.imageThumbnailURL)!
                            let request = URLRequest(url: imgURL)
                            URLSession.shared.dataTask(with: request){(data: Data?, response: URLResponse?, error: Error?) -> Void in
                                if error != nil {
                                    print("Get image error: \(String(describing: error?.localizedDescription))")
                                } else {
                                    if data != nil {
                                        let image = UIImage(data: data!)
                                        photoImage.thumbLocalImage = image
                                    }
                                }
                            }
                            self.GalleryImages.append(photoImage)
                            // also place in GalleryPosts array
                            let photoPost = GalleryPost()
                            photoPost.imageThumbnailURL = photoImage.imageThumbnailURL
                            photoPost.imageId = photoImage.imageId
                            photoPost.thumbLocalImage = photoImage.thumbLocalImage
                            photoPost.caption = photoImage.imageTitle
                            photoPost.username = ""
                            photoPost.location = ""
                            photoPost.createdAt = Date()
                            photoPost.likes = 0
                            self.GalleryPosts.append(photoPost)
                        }
                    }
                    self.collectionView.reloadData()
                }
            } catch let serializationError {
                print(serializationError.localizedDescription)
            }
        })
    }
    
    // MARK: Database stuff
        // save it in our gallery
//        let photo = getNewItem()
//        photo.name = "Unknown"
//        photo.filepath = String(describing: imagePath)
//        photo.image = imageName
//        photo.createdAt = Date() as NSDate?
//        print("Add photo: \(String(describing: photo.name))")
//        addItemtoDB(photo)
//        collectionView?.reloadData()
//        dismiss(animated: true, completion: nil)

//    // get directory path to photos
//    func getDocumentsDirectory() -> URL {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let documentsDirectory = paths[0]
//        return documentsDirectory
//    }

    //
    // DATABASE FUNCTIONS
    //
    
    // open access to db context
    let dbContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
//    func getNewItem() -> Photo {
//        let item = Photo(context: dbContext)
//        item.name = "Unknown"
//        item.filepath = nil
//        item.image = nil
//        item.createdAt = Date() as NSDate?
//        return item
//    }
//    
//    func addItemtoDB(_ item: Photo) {
//        do {    // save the item into db
//            try dbContext.save()
//        } catch {
//            print("DB \(error)")
//        }
//    }
//    
//    func updateItemtoDB(_ item: Photo) {
//        if dbContext.hasChanges {
//            do {    // save the item into db
//                try dbContext.save()
//            } catch {
//                print("DB \(error)")
//            }
//        }
//    }
//    
//    func deleteItemfromDB(_ item: Photo) {
//        dbContext.delete(item)
//        do {
//            try dbContext.save()
//        } catch {
//            print("DB \(error)")
//        }
//    }
    
    func fetchPhotosFromDB() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")

        do {
            let result = try dbContext.fetch(request)
            Photos = result as! [Photo]
        } catch {
            print("DB \(error)")
        }

        // now add them to GalleryPosts array
        var photoPost = GalleryPost()
        for i in 0..<Photos.count {
            photoPost.imageThumbnailURL = ""
            photoPost.imageId = ""
//            photoPost.thumbLocalImage = Photos[i].image
            photoPost.caption = Photos[i].caption
            photoPost.username = ""
            photoPost.location = Photos[i].location
            photoPost.createdAt = Photos[i].createdAt as Date!
            photoPost.likes = Int(Photos[i].likes)
            self.GalleryPosts.append(photoPost)
        }
        self.collectionView.reloadData()
    }

}

extension GalleryViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: UICollectionViewDataSource

    // Tap cell - show the post
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "EditItem", sender: indexPath)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return GalleryPosts.count
    }

    // show photo gallery
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoViewCell
        let rowIndex = indexPath.row
//        let rowIndex = self.GalleryImages.count - (indexPath.row + 1)
        
        cell.backgroundColor = UIColor.black
        cell.imageView.image = GalleryPosts[rowIndex].thumbLocalImage
        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        return cell
    }

//        let galleryRowObj = self.GalleryImages[rowIndex] as GalleryImage
//        let imgURL: URL = URL(string: galleryRowObj.imageThumbnailURL)!
//        let request = URLRequest(url: imgURL)
//        
//        URLSession.shared.dataTask(with: request){(data: Data?, response: URLResponse?, error: Error?) -> Void in
//            if error != nil {
//                print("Get image error: \(String(describing: error?.localizedDescription))")
//            } else {
//                if data != nil {
//                    let image = UIImage(data: data!)
//                    galleryRowObj.thumbLocalImage = image
//                    
//                    DispatchQueue.main.async{
//                        cell.imageView.image = image
//                        
//                        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
//                        cell.imageView.layer.borderWidth = 2
//                        cell.imageView.layer.cornerRadius = 3
//                        cell.layer.cornerRadius = 7
//                    }
//                }
//            }
//        }
    // let photo = Photos[indexPath.item]
    // let path = getDocumentsDirectory().appendingPathComponent(photo.image!)
    // cell.imageView.image = UIImage(contentsOfFile: path.path)
    // make it fancy

}
