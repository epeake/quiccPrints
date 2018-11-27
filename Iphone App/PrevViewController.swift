//
//  PrevViewController.swift
//  quiccPrintsV2
//
//  Created by Anthony Turcios on 11/4/18.
//  Copyright © 2018 Anthony Turcios. All rights reserved.
//

import UIKit

class PrevViewController: UIViewController {
    
    var image: UIImage!
    @IBOutlet weak var photo: UIImageView!
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func processButton(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = self.image
    }
    

}
