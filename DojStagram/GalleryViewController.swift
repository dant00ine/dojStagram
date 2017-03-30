//
//  GalleryViewController.swift
//  DojStagram
//
//  Created by Paul Binneboese on 3/23/17.
//  Copyright © 2017 Daniel Thompson. All rights reserved.
//

import UIKit
import CoreData

class GalleryImage {
    var imageTitle : String!
    var imageThumbnailURL : String!
    var imageId : String!
    var thumbLocalImage : UIImage!
}

private let reuseIdentifier = "PhotoViewCell"

class GalleryViewController: UIViewController, UIToolbarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var shouldFetchNewData = true
    var dataArray = [GalleryImage]()
    let httpHelper = HTTPHelper()

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func addPhoto(_ sender: UIBarButtonItem) {
        addAPhoto()
    }
    
    var Photos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPhotos()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Register cell classes
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
            
            if shouldFetchNewData {
                shouldFetchNewData = false
                //self.setNavigationItems()
                loadPhotoData()
            }
            
            if comparison != ComparisonResult.orderedAscending {
                //self.logoutBtnTapped()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func loadPhotoData(){
        let httpRequest = httpHelper.buildRequest(path: "get_user_photos", method: "GET", authType: HTTPRequestAuthType.HTTPTokenAuth)
        
        httpHelper.sendRequest(request: httpRequest, completion: {(data:Data?, error:Error?) in
            
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error: error!)
                let errorAlert = UIAlertView(title: "Error", message: errorMessage, delegate: nil, cancelButtonTitle: "OK")
                errorAlert.show()
                
                return
            }
            
            
            do {
                
                if let jsonDataArray = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Array<Any> {
                    
                    if jsonDataArray != nil {
                        for imageData in jsonDataArray {
                            
                            if let imageDataDict = imageData as? NSDictionary {
                                let photoPost = GalleryImage()
                                
                                photoPost.imageTitle = imageDataDict.value(forKey:"title") as! String
                                photoPost.imageId = imageDataDict.value(forKey:"random_id") as! String
                                photoPost.imageThumbnailURL = imageDataDict.value(forKey:"image_url") as! String
                                
                                self.dataArray.append(photoPost)

                            }
                           
                        }
                        
                        self.collectionView?.reloadData()
                    }
                    
                }
                
            } catch let serializationError {
                print(serializationError.localizedDescription)
            }
            
            
        
        })
    }
    
    
    
    
    // MARK: Camera roll functionality

    // add new photo to gallery
    func addAPhoto() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // select photo from Photo Library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = UIImageJPEGRepresentation(image, 80) {
            try? jpegData.write(to: imagePath)
        }
        // save it in our gallery
        let photo = getNewItem()
        photo.name = "Unknown"
        photo.filepath = String(describing: imagePath)
        photo.image = imageName
        photo.createdAt = Date() as NSDate?
        print("Add photo: \(photo.name)")
        addItemtoDB(photo)
        collectionView?.reloadData()
        dismiss(animated: true)
    }

    // get directory path to photos
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    
    //
    // DATABASE FUNCTIONS
    //
    
    // open access to db context
    let dbContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    func getNewItem() -> Photo {
        let item = Photo(context: dbContext)
        item.name = "Unknown"
        item.filepath = nil
        item.image = nil
        item.createdAt = Date() as NSDate?
        return item
    }
    
    func addItemtoDB(_ item: Photo) {
        do {    // save the item into db
            try dbContext.save()
        } catch {
            print("DB \(error)")
        }
    }
    
    func updateItemtoDB(_ item: Photo) {
        if dbContext.hasChanges {
            do {    // save the item into db
                try dbContext.save()
            } catch {
                print("DB \(error)")
            }
        }
    }
    
    func deleteItemfromDB(_ item: Photo) {
        dbContext.delete(item)
        do {
            try dbContext.save()
        } catch {
            print("DB \(error)")
        }
    }
    
    func fetchPhotos() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        //        request.predicate = NSPredicate(format: "name == %@", false as CVarArg)
        
        do {
            let result = try dbContext.fetch(request)
            Photos = result as! [Photo]
        } catch {
            print("DB \(error)")
        }
        self.collectionView.reloadData()
    }

}

extension GalleryViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Photos.count
    }

    // show photo gallery
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoViewCell
        
        let rowIndex = self.dataArray.count - (indexPath.row + 1)
        let galleryRowObj = self.dataArray[rowIndex] as GalleryImage
        
        cell.backgroundColor = UIColor.black
        
        let imgURL: URL = URL(string: galleryRowObj.imageThumbnailURL)!
        
        let request = URLRequest(url: imgURL)
        
        URLSession.shared.dataTask(with: request){(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                print("Get image error: \(error?.localizedDescription)")
            } else {
                if data != nil {
                    let image = UIImage(data: data!)
                    
                    DispatchQueue.main.async{
                        cell.imageView.image = image
                        
                        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
                        cell.imageView.layer.borderWidth = 2
                        cell.imageView.layer.cornerRadius = 3
                        cell.layer.cornerRadius = 7
                    }
                }
            }
        }
        
        return cell
        // let photo = Photos[indexPath.item]
        // cell.name.text = photo.name
        
        // let path = getDocumentsDirectory().appendingPathComponent(photo.image!)
        // cell.imageView.image = UIImage(contentsOfFile: path.path)
        // make it fancy
        
    }

    // add a name to photo
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = Photos[indexPath.item]
        
        let ac = UIAlertController(title: "Rename photo", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self, ac] _ in
            let newName = ac.textFields![0]
            photo.name = newName.text!
            self.updateItemtoDB(photo)
            self.collectionView?.reloadData()
        })
        present(ac, animated: true)
    }
    

}
