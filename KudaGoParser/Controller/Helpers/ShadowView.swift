//
//  ShadowView.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 29.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    private func setupShadow() {
        
        self.setupShadowEffect(cornerRadius: 16, shadowRadius: 12, widthOffset: 0, heightOffset: 0)
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 16).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
    }
}
