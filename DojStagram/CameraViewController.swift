//
//  CameraViewController.swift
//  DojStagram
//
//  Created by Daniel Thompson on 3/17/17.
//  Copyright © 2017 Daniel Thompson. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    
    // outlet connections and global variables ----
    
    @IBOutlet weak var cameraView: UIView!
    
    @IBAction func takePhoto(_ sender: UIButton) {
        tookSnapshot = true
    }
    @IBAction func cancel(_ sender: UIButton) {
        tookSnapshot = false
        stopCaptureSession()
        dismiss(animated: true, completion: nil)
    }

    
    var delegate: PhotoViewController?

    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice!
    var previewLayer : AVCaptureVideoPreviewLayer!
    
    var tookSnapshot = false
    
    
    // view life cycle ----------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tookSnapshot = false
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopCaptureSession()
    }
    
    
    
    // camera session preparation ------------------
    
    func prepareCamera(){
        captureSession.sessionPreset = AVCaptureSessionPresetLow
        
        if let availableDevices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .back).devices {
            captureDevice = availableDevices.first
            beginSession()
        }
        
    }
    
    func beginSession(){
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(captureDeviceInput)
            
        } catch let avError {
            print(avError.localizedDescription)
        }
                
        if let newPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            
            previewLayer = newPreviewLayer
            cameraView.layer.addSublayer(self.previewLayer)
            
            previewLayer.position = CGPoint(x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
            previewLayer.bounds = cameraView.frame
            
            captureSession.startRunning()
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)]
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            
            if captureSession.canAddOutput(dataOutput) {
                captureSession.addOutput(dataOutput)
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            }
            
            captureSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.dojstagram.captureQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
            
//            print("preview layer frame: \(previewLayer.frame)")
//            print("cameraView layer frame: \(cameraView.layer.frame)")
            
        }
        
    }
    
    func stopCaptureSession () {
        self.captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }
    }
    
    
    // MARK: Take photo code ------------
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        if tookSnapshot {
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
                delegate?.returnedImage(success: tookSnapshot, newImage: image)
                stopCaptureSession()
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func getImageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
            
        }
        
        return nil
    }
    
    
    // MARK: Camera functionality -------
    
    
    func focusTo(focusPoint : CGPoint) {
        if let device = captureDevice {
            do {
                
                try device.lockForConfiguration()
                
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = AVCaptureFocusMode.autoFocus
                }
                
                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureExposureMode.autoExpose
                }
                
                device.unlockForConfiguration()
                
            } catch let captureDeviceError {
                
                print(captureDeviceError)
                
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint: UITouch = touches.first!
        // needs work!!
//        let cameraViewSize = cameraView.bounds.size
        let focusPoint = CGPoint(x: touchPoint.location(in: cameraView).x, y: touchPoint.location(in: cameraView).y)
        
        focusTo(focusPoint: focusPoint)
    }
    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let anyTouch = touches.first
//        let touchPercent = (anyTouch?.location(in: cameraView).x)! / screenWidth
//        focusTo(value: Float(touchPercent))
//    }
//    
    
}
