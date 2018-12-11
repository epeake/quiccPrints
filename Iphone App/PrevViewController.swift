//
//  PrevViewController.swift
//  quiccPrintsV2
//
//  Created by Anthony Turcios on 11/4/18.
//  Copyright © 2018 Anthony Turcios. All rights reserved.
//

import UIKit
import Alamofire

class PrevViewController: UIViewController {
    
    var image: UIImage!
    @IBOutlet weak var photo: UIImageView!
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBAction func backButton(_ sender: Any) {
      Loader.instance.hide_loader()
      dismiss(animated: true, completion: nil)
    }
    @IBAction func processButton(_ sender: Any) {
      Loader.instance.show_loader()
      upload(image: self.image)
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      photo.image = self.image
    }
   
   // upload image to node js server and compress! otherwise there is too much latency
   func upload(image: UIImage) {
      //first reorient the image to be portrait
      let rotate_img = imageOrientation(image)
      guard let data = rotate_img.jpegData(compressionQuality: 0.9) else {
         return
      }
      
      
      //upload the image
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
      
      //now make the request for information on the image
//      Alamofire.request("https://httpbin.org/result").responseJSON { response in
//         print("Request: \(String(describing: response.request))")   // original url request
//         print("Response: \(String(describing: response.response))") // http url response
//         print("Result: \(response.result)")                         // response serialization result
//
//         if let json = response.result.value {
//            print("JSON: \(json)") // serialized json response
//         }
//
//         if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//            print("Data: \(utf8Text)") // original server data as UTF8 string
//         }
//      }

   }
   
   func createAlert(message: String) {
      let split_message: [String] = message.components(separatedBy: "\\n")
      let indexStartOfText = split_message[0].index(split_message[0].startIndex, offsetBy: 1)
      
      let new_message = split_message[0][indexStartOfText...] + "\n" + split_message[1] + "\n" + split_message[2] + "\n" + split_message[3] + "\n" + split_message[4] + "\n"
      
      let paddedString = new_message.leftJustified(width: 5)
//      print(new_message)
      let alert = UIAlertController(title: "About Your Print", message: paddedString, preferredStyle: UIAlertController.Style.alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
         })
      )
      self.present(alert, animated: true, completion: nil)
   }
   
   // transform the image so that when it is sent, it is still in portrait mode
   func imageOrientation(_ src:UIImage)->UIImage {
      if src.imageOrientation == UIImage.Orientation.up {
         return src
      }
      var transform: CGAffineTransform = CGAffineTransform.identity
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
    
//    func saveToCameraRoll() {
//         UIImageWriteToSavedPhotosAlbum(photo.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
//    }
//
//    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
//        if let error = error {
//            // we got back an error!
//            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default))
//            present(ac, animated: true)
//        }
//    }
}

extension String {
   func leftJustified(width: Int, truncate: Bool = false) -> String {
      guard width > count else {
         return truncate ? String(prefix(width)) : self
      }
      return self + String(repeating: " ", count: width - count)
   }
}

