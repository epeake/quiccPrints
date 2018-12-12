//
//  PrevViewController.swift
//  quiccPrintsV2
//
//  Created by Anthony Turcios on 11/4/18.
//  Copyright © 2018 Anthony Turcios. All rights reserved.
//
import UIKit
import Alamofire


/*
* The PrevViewController essentially extends the UIViewController Class
* and will be used to display the image that was captured during the camera
* preview session.
*
* Since we are using an express server for handling the images, I made use of the Almofire library 
* to handle the put request to send data.
*/
class PrevViewController: UIViewController {
    
    var image: UIImage!
    @IBOutlet weak var photo: UIImageView! 
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    /*
    * Event listener for the back button,
    * when pressed return to live preview
    */
    @IBAction func backButton(_ sender: Any) {
      Loader.instance.hide_loader()
      dismiss(animated: true, completion: nil)
    }
    /*
    * Event listener for the process button
    * when pressed uplaod image to server for processing
    */
    @IBAction func processButton(_ sender: Any) {
      Loader.instance.show_loader()
      upload(image: self.image)
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      photo.image = self.image
    }
   

    /*
    * First rotates the image so that the server ahs the same portrait view that
    * the app gave the user
    */
   func upload(image: UIImage) {
      //first reorient the image to be portrait
      let rotate_img = imageOrientation(image)
      guard let data = rotate_img.jpegData(compressionQuality: 0.9) else {
         return
      }
      //upload the image as a put request
      Alamofire.upload(multipartFormData: { (form) in
         form.append(data, withName: "file", fileName: "file.jpg", mimeType: "image/jpg")
      }, to: "https://quicc-prints-aturc.c9users.io/images", encodingCompletion: { result in
         switch result {
         case .success(let upload, _, _):
             upload.responseString { response in
               Loader.instance.hide_loader()
               self.createAlert(message: response.value ?? "something happened")
             }
         case .failure(let encodingError):
             print(encodingError)
         }
      })
   }
   
    /*
    * After the image has been processed, the server will send a response with the 
    * statistics on the the thumb print
    * Show user using an alert popup
    * 
    * The string returned from the server has a ton of extra characters that are sent in the response like '\n'
    * '#'
    */
   func createAlert(message: String) {
      let split_message: [String] = message.components(separatedBy: "\\n")
      let indexStartOfText = split_message[0].index(split_message[0].startIndex, offsetBy: 1)
      let new_message = split_message[0][indexStartOfText...] + "\n" + split_message[1] + "\n" + split_message[2] + "\n" + split_message[3] + "\n" + split_message[4] + "\n"
      let paddedString = new_message.leftJustified(width: 5)
      let alert = UIAlertController(title: "About Your Print", message: paddedString, preferredStyle: UIAlertController.Style.alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
         })
      )
      self.present(alert, animated: true, completion: nil)
   }
   
   /*
    * In many cases the image will not have the same portrait orientaiton as the user is seeing,
    * this implies that when the server saves the image it will be rotated.
    */
   func imageOrientation(_ src:UIImage)->UIImage {
      // if the orientation is corrent stop
      if src.imageOrientation == UIImage.Orientation.up {
         return src
      }
      var transform: CGAffineTransform = CGAffineTransform.identity

      // find which orientation the image has and transform it appropriately
      switch src.imageOrientation {
         case UIImage.Orientation.down, UIImage.Orientation.downMirrored:
            transform = transform.translatedBy(x: src.size.width, y: src.size.height)
            transform = transform.rotated(by: .pi)
            break
         case UIImage.Orientation.left, UIImage.Orientation.leftMirrored:
            transform = transform.translatedBy(x: src.size.width, y: 0)
            transform = transform.rotated(by: .pi/2)
            break
         case UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: src.size.height)
            transform = transform.rotated(by: -.pi/2)
            break
         case UIImage.Orientation.up, UIImage.Orientation.upMirrored:
            break
      }

      // post processing, ensure that the scaling is also correct
      switch src.imageOrientation {
         case UIImage.Orientation.upMirrored, UIImage.Orientation.downMirrored:
            transform.translatedBy(x: src.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
         case UIImage.Orientation.leftMirrored, UIImage.Orientation.rightMirrored:
            transform.translatedBy(x: src.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
         case UIImage.Orientation.up, UIImage.Orientation.down, UIImage.Orientation.left, UIImage.Orientation.right:
            break
      }
      
      let ctx:CGContext = CGContext(data: nil, width: Int(src.size.width), height: Int(src.size.height), bitsPerComponent: (src.cgImage)!.bitsPerComponent, bytesPerRow: 0, space: (src.cgImage)!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
      
      ctx.concatenate(transform)
      
      switch src.imageOrientation {
         case UIImage.Orientation.left, UIImage.Orientation.leftMirrored, UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.height, height: src.size.width))
            break
         default:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.width, height: src.size.height))
            break
      }
      
      let cgimg:CGImage = ctx.makeImage()!
      let img:UIImage = UIImage(cgImage: cgimg)
      
      return img
   }
}

// my attempt to add a method to the string class to allow for left justification of text
extension String {
   func leftJustified(width: Int, truncate: Bool = false) -> String {
      guard width > count else {
         return truncate ? String(prefix(width)) : self
      }
      return self + String(repeating: " ", count: width - count)
   }
}

