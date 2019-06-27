//
//  DropShadowEffect.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 09.06.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

class DropShadowEffect {
    
    class func setupProperties(view: UIView, cornerRadius: CGFloat, shadowRadius: CGFloat, widthOffset: Double, heightOffset: Double) {
        view.layer.cornerRadius = cornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: widthOffset, height: heightOffset)
        view.layer.masksToBounds = false
        view.layer.shadowRadius = shadowRadius
        view.layer.shadowOpacity = 0.1
    }
    
}
