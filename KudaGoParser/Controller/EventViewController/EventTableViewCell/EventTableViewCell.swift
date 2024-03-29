//
//  TableViewCell.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 14.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

final class EventTableViewCell: UITableViewCell {
    
    // MARK: - Constants
    
    private enum Constants {
        static let cornerRadius: CGFloat = 16
    }
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var placeStackView: UIStackView!
    @IBOutlet weak var priceImage: UIImageView!
    @IBOutlet weak var dateImage: UIImageView!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundView.layer.masksToBounds = true
        roundView.layer.cornerRadius = Constants.cornerRadius
    }
    
}
