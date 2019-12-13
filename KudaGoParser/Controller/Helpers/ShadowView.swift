//
//  ShadowView.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 29.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

final class ShadowView: UIView {
    
    private enum Constants {
        static let cornerRadius: CGFloat = 16
        static let shadowRadius: CGFloat = 12
    }
    
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    private func setupShadow() {
        self.setupShadowEffect(cornerRadius: Constants.cornerRadius, shadowRadius: Constants.shadowRadius, widthOffset: 0, heightOffset: 0)
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: Constants.cornerRadius).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
