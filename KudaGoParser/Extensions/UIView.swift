//
//  UIView.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 26.11.2019.
//  Copyright © 2019 nikita. All rights reserved.
//

import UIKit

extension UIView {
    func setupShadowEffect(cornerRadius: CGFloat, shadowRadius: CGFloat, widthOffset: Double, heightOffset: Double) {
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: widthOffset, height: heightOffset)
        self.layer.masksToBounds = false
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = 0.1
    }
}
