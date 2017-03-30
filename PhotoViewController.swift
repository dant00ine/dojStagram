//
//  PhotoViewController.swift
//  DojStagram
//
//  Created by Daniel Thompson on 3/17/17.
//  Copyright © 2017 Daniel Thompson. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    
    var takenPhoto:UIImage?
    
    let httpHelper = HTTPHelper()
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func goBack(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goSave(_ sender: UIButton) {
        
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postPhoto(_ sender: UIButton) {
        
        let imgData: Data? = UIImagePNGRepresentation(takenPhoto!)
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
    
    
    @IBAction func sharePhoto(_ sender: UIBarButtonItem) {
        shareAPhoto()
    }
    
    @IBAction func renamePhoto(_ sender: UIBarButtonItem) {
        renameAPhoto()
    }
    @IBAction func editPhoto(_ sender: UIBarButtonItem) {
        editAPhoto()
    }
    @IBAction func deletePhoto(_ sender: UIBarButtonItem) {
        deleteAPhoto()
    }
    
    //
    // Photo Manipulation stuff
    //
    
    // save an image to the photo library
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
    
    // take a new photo, add to gallery
    func takeAPhoto() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cameraVC = storyboard.instantiateViewController(withIdentifier: "CameraVC") as! CameraViewController
        //        photoVC.takenPhoto = image
        present(cameraVC, animated: true)
    }
    
    // edit a photo in gallery
    func editAPhoto() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let photoVC = storyboard.instantiateViewController(withIdentifier: "PhotoVC") as! PhotoViewController
        //        photoVC.takenPhoto = image
        present(photoVC, animated: true)
    }
    
    // share a photo with friends
    func shareAPhoto() {
        
    }
    
    // rename a photo in gallery
    func renameAPhoto() {
        
    }
    
    // delete a photo from gallery
    func deleteAPhoto() {
        
    }
    
    //
    //  View Controller stuff
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let availableImage = takenPhoto {
            imageView.image = availableImage
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
    
}
