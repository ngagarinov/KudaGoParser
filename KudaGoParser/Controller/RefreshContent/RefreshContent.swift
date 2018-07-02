//
//  RefreshContent.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 01.06.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

class RefreshContent: UIView {
    
    var rotation: CABasicAnimation?
    @IBOutlet weak var loader: UIImageView!
    
    func startAnimation() {
        rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation?.toValue = NSNumber(value: Double.pi * 2)
        rotation?.duration = 1
        rotation?.isCumulative = true
        rotation?.repeatCount = Float.greatestFiniteMagnitude
        loader.layer.add(rotation!, forKey: "rotationAnimation")
        loader.isHidden = false
    }
    
    func stopAnimation() {
        self.loader.layer.removeAnimation(forKey: "rotationAnimation")
    }
    
    
}
