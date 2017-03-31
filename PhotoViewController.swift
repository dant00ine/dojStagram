//
//  PhotoViewController.swift
//  DojStagram
//
//  Created by Daniel Thompson on 3/17/17.
//  Copyright © 2017 Daniel Thompson. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var selectedPhoto: UIImage!
    var photoChanged: Bool!

    let httpHelper = HTTPHelper()
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postPhoto(_ sender: UIBarButtonItem) {
        postAPhoto()
    }
    
    @IBOutlet weak var captionText: UITextField!
    @IBOutlet weak var locationText: UITextField!
    
    @IBAction func takePhoto(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "TakePhotoSegue", sender: nil)
    }
    
    @IBAction func getPhoto(_ sender: UIBarButtonItem) {
        getAPhoto()
    }
    @IBAction func editPhoto(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "EditPhotoSegue", sender: nil)
    }
    @IBAction func deletePhoto(_ sender: UIBarButtonItem) {
        deleteAPhoto()
    }
    
    //
    // Photo Manipulation stuff
    //

    // post a photo
    func postAPhoto() {
        if selectedPhoto == nil {
            return
        }
        let imgData: Data? = UIImagePNGRepresentation(selectedPhoto)
        let httpRequest = httpHelper.uploadRequest(path: "upload_photo", data: imgData!, title: "WOOT TYTLE")
        
        httpHelper.sendRequest(request: httpRequest, completion: {(data:Data?, error:Error?) in
            
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error: error!)
                self.displayErrorAlertMessage(alertMessage: errorMessage)
                
                return
            }
            
            do {
                let jsonDataDict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                
                let galleryImgObjNew = GalleryImage()
                
                print("response from image upload: \(jsonDataDict)")
                
                galleryImgObjNew.imageId = jsonDataDict.value(forKey: "random_id") as! String
                galleryImgObjNew.imageTitle = jsonDataDict.value(forKey: "title") as! String
                galleryImgObjNew.imageThumbnailURL = jsonDataDict.value(forKey: "image_url") as! String
                
                self.dismiss(animated: true, completion: nil)
                
            } catch let serializationError {
                print(serializationError.localizedDescription)
            }
            
        })
    }
    
    // get a photo from the photo library
    func getAPhoto() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        
        selectedPhoto = image
        imageView.image = selectedPhoto
        dismiss(animated: true)
    }

    // new image returned from Camera or Edit View
    func returnedImage(success: Bool, newImage: UIImage) {
        photoChanged = success
        if photoChanged == true {
            selectedPhoto = newImage
            if selectedPhoto != nil {
                imageView.image = selectedPhoto
                UIImageWriteToSavedPhotosAlbum(selectedPhoto, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    // save a photo into the photo library
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error { // couldn't save image, display an alert
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {    // image saved
            let ac = UIAlertController(title: "Saved!", message: "Image saved to photo library", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    // delete a photo from library
    func deleteAPhoto() {   // stub for now
    }
    
    //
    //  View Controller stuff
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // display last selected photo
        if selectedPhoto != nil {
            imageView.image = selectedPhoto
        }
        photoChanged = false
        // dismiss keyboard upon tap gesture
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // verify user is logged in, else reroute
        let isUserLoggedIn =  UserDefaults.standard.bool(forKey: "userLoggedIn")
        
        if(!isUserLoggedIn){
            print("user not logged in")
            if let loginController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginPageViewController {
                self.tabBarController?.present(loginController, animated: true, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayErrorAlertMessage(alertTitle:String = "Error DX", completion: (() -> Void)? = nil, alertMessage:String){
        let myAlert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }

    // segues to Camera and Edit Views
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditPhotoSegue" {
            let VC = segue.destination as! EditViewController
            VC.delegate = self
            VC.currentImage = selectedPhoto
            photoChanged = false
        }
        else if segue.identifier == "TakePhotoSegue" {
            let VC = segue.destination as! CameraViewController
            VC.delegate = self
            photoChanged = false
        }
    }
    
}
