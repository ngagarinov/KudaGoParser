//
//  ShadowView.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 29.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    
    var dropShadowEffect = DropShadowEffect()
    
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    private func setupShadow() {
        
        dropShadowEffect.setupProperties(view: self, cornerRadius: 16, shadowRadius: 12, widthOffset: 0, heightOffset: 0)
//        self.layer.cornerRadius = 16
//        self.layer.shadowOffset = CGSize(width: 0, height: 0)
//        self.layer.shadowRadius = 12
//        self.layer.shadowOpacity = 0.1
//        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 16).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
    }
}
