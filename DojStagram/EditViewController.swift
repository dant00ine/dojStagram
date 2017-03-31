//
//  EditViewController.swift
//  DojStagram
//
//  Created by Paul Binneboese on 3/29/17.
//  Copyright © 2017 Daniel Thompson. All rights reserved.
//

import UIKit
import CoreImage

class EditViewController: UIViewController {

    var delegate: PhotoViewController?
    var currentImage: UIImage?
    
    var context: CIContext!
    var currentFilter: CIFilter!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var intensity: UISlider!
    @IBAction func changeFilter(_ sender: UIButton) {
        changeFilterType()
    }
    @IBAction func save(_ sender: UIButton) {
        if let currentImage = imageView.image {
            delegate?.returnedImage(success: true, newImage: currentImage)
        }
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func intensityChanged(_ sender: UISlider) {
        applyProcessing()
    }

    // MARK: View Controller stuff
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentImage != nil {
            imageView.image = currentImage
        }
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
        let beginImage = CIImage(image: currentImage!)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Filtering stuff

    func changeFilterType() {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    func setFilter(action: UIAlertAction) {
        // make sure we have a valid image before continuing!
        guard currentImage != nil else { return }
        
        currentFilter = CIFilter(name: action.title!)
        let beginImage = CIImage(image: currentImage!)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    func applyProcessing() {
        // make sure we have a valid image before continuing!
        guard currentImage != nil else { return }

        let inputKeys = currentFilter.inputKeys
        print(inputKeys)
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x: currentImage!.size.width / 2, y: currentImage!.size.height / 2), forKey: kCIInputCenterKey) }
        
        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            // display the processed image
            self.imageView.image = processedImage
        }
    }

}
