//
//  ViewController.swift
//  quiccPrintsV2
//
//  Created by Anthony Turcios on 11/4/18.
//  Copyright © 2018 Anthony Turcios. All rights reserved.
//

import UIKit
import AVFoundation

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
    
    func setupCapSesh() {
        capSesh.sessionPreset = AVCaptureSession.Preset.photo
    }
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
    func setupPrevLayer() {
        camPrevLayer = AVCaptureVideoPreviewLayer(session: capSesh)
        camPrevLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        camPrevLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        camPrevLayer?.frame = self.view.frame
        let xCor = self.view.frame.origin.x
        let yCor = self.view.frame.origin.y
        let overlayImView = UIImageView(image: UIImage(named: "Image.png"))
//        print(overlayImView.frame.height)
//        print(overlayImView.frame.width)
        overlayImView.frame = CGRect(x: xCor, y: yCor, width: 700, height: 800)
        self.view.addSubview(overlayImView)
        self.view.layer.insertSublayer(camPrevLayer!, at: 0)
    }
    func startRunCapSesh() {
        capSesh.startRunning()
    }
    @IBAction func cameraButton_TouchInside(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .on
        photoOut?.capturePhoto(with: settings, delegate: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotoSegue" {
            let prevVC = segue.destination as! PrevViewController
            prevVC.image = self.image 
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
