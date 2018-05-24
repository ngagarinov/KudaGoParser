//
//  TableViewCell.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 14.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    
    
    

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var placeStackView: UIStackView!
    @IBOutlet weak var priceImage: UIImageView!
    @IBOutlet weak var dateImage: UIImageView!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var roundVIew: UIView!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundVIew.layer.masksToBounds = true
        roundVIew.layer.cornerRadius = 16
        shadowView.layer.cornerRadius = 16
//        roundVIew.layer.borderWidth = 1.0
//        roundVIew.layer.borderColor = UIColor.white.cgColor
        shadowView.layer.shadowColor = UIColor.lightGray.cgColor
        shadowView.layer.shadowRadius = 12.0
        shadowView.layer.shadowOpacity = 0.25
        shadowView.layer.shadowOffset = CGSize(width:0, height: 4)


  
    }

    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        let f = contentView.frame
//        let fr = UIEdgeInsetsInsetRect(f, UIEdgeInsetsMake(0, 0, 10, 0))
//        contentView.frame = fr
//    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
