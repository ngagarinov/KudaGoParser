//
//  TableViewCell.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 14.05.2018.
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
        self.layer.cornerRadius = 16
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 12
        self.layer.shadowOpacity = 0.12
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 16).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}

class TableViewCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var placeStackView: UIStackView!
    @IBOutlet weak var priceImage: UIImageView!
    @IBOutlet weak var dateImage: UIImageView!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roundView.layer.masksToBounds = true
        roundView.layer.cornerRadius = 16
//        shadowView.layer.cornerRadius = 16
//        shadowView.layer.shadowColor = UIColor.black.cgColor
//        shadowView.layer.shadowRadius = 12
//        shadowView.layer.shadowOpacity = 0.2
//        shadowView.layer.shadowOffset = CGSize(width:0, height: 0)
//        shadowView.layer.masksToBounds = false
        
    }

    
}
