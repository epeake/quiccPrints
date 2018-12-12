//
//  Loader.swift
//  quiccPrintsV2
//
//  Created by Anthony Turcios on 12/4/18.
//  Copyright © 2018 Anthony Turcios. All rights reserved.
//

import UIKit

class Loader: UIView {
    
    static let instance = Loader()
    
    lazy var trans_view: UIView = {
       let trans_view = UIView(frame: UIScreen.main.bounds)
        trans_view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        trans_view.isUserInteractionEnabled = false
        return trans_view
    }()
    
    lazy var gif_img: UIImageView = {
       let gif_img = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        gif_img.contentMode = .scaleAspectFit
        gif_img.center = trans_view.center
        gif_img.isUserInteractionEnabled = false
        gif_img.loadGif(name: "load_final")
        return gif_img
    }()
    
    func show_loader() {
        self.addSubview(trans_view)
        self.trans_view.addSubview(gif_img)
        self.trans_view.bringSubviewToFront(self.gif_img)
        UIApplication.shared.keyWindow?.addSubview(trans_view)
    }
    
    func hide_loader() {
        self.trans_view.removeFromSuperview()
    }
}
