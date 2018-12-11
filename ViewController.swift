//  ViewController.swift
//  quiccPrintsV2
//
//  Created by Anthony Turcios on 11/4/18.
//  Copyright © 2018 Anthony Turcios. All rights reserved.
//
import UIKit
import AVFoundation

/*
 * ViewController class will host the camera session
 * when the device first loads the first activity, this class will initialize a camera session
 *
 * The session is made using the AVFoundation Framework
 */
class ViewController: UIViewController {
    
    var capSesh: AVCaptureSession = AVCaptureSession()
    var backCam: AVCaptureDevice?
    var photoOut: AVCapturePhotoOutput?
    var camPrevLayer: AVCaptureVideoPreviewLayer?
    var image: UIImage?
    var flashMode = AVCaptureDevice.FlashMode.off

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCapSesh()
        setupDevice()
        setupInputOutput()
        setupPrevLayer()
        startRunCapSesh()
    }
    // init the capture session
    func setupCapSesh() {
        capSesh.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    // specify that the back camera is being used
    func setupDevice() {
        let deviceDiscSesh = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        let devices = deviceDiscSesh.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCam = device
                break
            }
        }  
    }
    
    // specify method of capturing input as video stream
    func setupInputOutput() {
        do {
            let capDevInput = try AVCaptureDeviceInput(device: backCam!)
            capSesh.addInput(capDevInput)
            photoOut = AVCapturePhotoOutput()
            photoOut?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            capSesh.addOutput(photoOut!)
        } catch {
            print(error)
        }
    }
    
    // init the actual capture session to show it to the screen
    // also overlay the thumbprint image
    func setupPrevLayer() {
        camPrevLayer = AVCaptureVideoPreviewLayer(session: capSesh)
        camPrevLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        camPrevLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        camPrevLayer?.frame = self.view.frame
        let overlayImView = UIImageView(frame: self.view.bounds)
        overlayImView.image = UIImage(named: "Image.png")
        overlayImView.contentMode = .scaleAspectFit
        
        self.view.addSubview(overlayImView)
        self.view.layer.insertSublayer(camPrevLayer!, at: 0)
    }
    
    func startRunCapSesh() {
        capSesh.startRunning()
    }
    
    // event listener for the capture camera button
    // on press the flash will turn on and the device will capture
    @IBAction func cameraButton_TouchInside(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .on
        photoOut?.capturePhoto(with: settings, delegate: self)
    }
    
    // sets up the next "activity" to be the PrevViewController
    // passes image data along
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotoSegue" {
            let prevVC = segue.destination as! PrevViewController
            prevVC.image = self.image 
        }
    }
    
    // allow user to tap to focus
    // helps get better quality images of the thumb prints
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchP = touches.first
        let screenSize = self.view.bounds.size
        let x = touchP!.location(in: self.view).y / screenSize.height
        let y = 1.0 - (touchP?.location(in: self.view).x)!/screenSize.width
        let focPoint = CGPoint(x: x, y: y)

        if let dev = backCam {
            do {
                try dev.lockForConfiguration()
                
                dev.focusPointOfInterest = focPoint
                dev.focusMode = .autoFocus
                dev.exposurePointOfInterest = focPoint
                dev.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                dev.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }

}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imData = photo.fileDataRepresentation() {
            image = UIImage(data: imData)
            performSegue(withIdentifier: "showPhotoSegue", sender: nil)
        }
    }
}
