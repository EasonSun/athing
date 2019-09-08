//
//  ViewController.swift
//  AV Foundation
//
//  Created by Pranjal Satija on 5/22/17.
//  Copyright © 2017 Pranjal Satija. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    @IBOutlet fileprivate var captureButton: UIButton!
    
    ///Displays a preview of the video output generated by the device's cameras.
    @IBOutlet fileprivate var capturePreviewView: UIView!
    
    ///Allows the user to put the camera in photo mode.
    @IBOutlet fileprivate var photoModeButton: UIButton!
    @IBOutlet fileprivate var toggleCameraButton: UIButton!
    @IBOutlet fileprivate var toggleFlashButton: UIButton!
    
    ///Allows the user to put the camera in video mode.
    @IBOutlet fileprivate var videoModeButton: UIButton!
    
    let cameraController = CameraController()
    
    override var prefersStatusBarHidden: Bool { return true }
    
}

extension ViewController {
    override func viewDidLoad() {
        
        func configureCameraController() {
            cameraController.prepare {(error) in
                if let error = error {
                    print(error)
                }
                
                try? self.cameraController.displayPreview(on: self.capturePreviewView)
            }
        }
        
        func styleCaptureButton() {
            captureButton.layer.borderColor = UIColor.black.cgColor
            captureButton.layer.borderWidth = 2
            
            captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
        }
        
        func configBLEController() {
            
        }
        
        styleCaptureButton()
        configureCameraController()
        configBLEController()
        BLEController.setLightingParam(CameraController.getLightingParam())
        
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            // save photo to camera roll; TODO how to really save into the app
            // TODO in our system, only save at last shooting. Maybe just 2 classes
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
}

extension ViewController {
    @IBAction func toggleFlash(_ sender: UIButton) {
        if cameraController.flashMode == .on {
            cameraController.flashMode = .off
            toggleFlashButton.setImage(#imageLiteral(resourceName: "Flash Off Icon"), for: .normal)
        }
            
        else {
            cameraController.flashMode = .on
            toggleFlashButton.setImage(#imageLiteral(resourceName: "Flash On Icon"), for: .normal)
        }
    }
    
    @IBAction func switchCameras(_ sender: UIButton) {
        do {
            try cameraController.switchCameras()
        }
            
        catch {
            print(error)
        }
        
        switch cameraController.currentCameraPosition {
        case .some(.front):
            toggleCameraButton.setImage(#imageLiteral(resourceName: "Front Camera Icon"), for: .normal)
            
        case .some(.rear):
            toggleCameraButton.setImage(#imageLiteral(resourceName: "Rear Camera Icon"), for: .normal)
            
        case .none:
            return
        }
    }
    
    @IBAction func captureImage(_ sender: UIButton) {
        // TODO cannot start right away. What is the start signal? Installed on dock, or intensity max detected, i.e the door closed. In a micro wave, operations are done after lid closes
        // TODO can I do everthing in sequence here?
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            // save photo to camera roll; TODO how to really save into the app
            // TODO in our system, only save at last shooting. Maybe just 2 classes
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
    
}

