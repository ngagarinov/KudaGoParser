//
//  DetailViewCell.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 24.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit
import MapKit

class DetailViewCell: UITableViewCell,UIScrollViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var placeStackView: UIStackView!
    @IBOutlet weak var getDirectionsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pageControl.superview?.bringSubview(toFront: pageControl)
        scrollView.delegate = self
        
        setupGetDirectionsButtonAppearance()

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
    }
    
    func setupGetDirectionsButtonAppearance() {
        getDirectionsButton.superview?.bringSubview(toFront: getDirectionsButton)
        getDirectionsButton.backgroundColor = .white
        getDirectionsButton.setTitle("Проложить маршрут", for: .normal)
        getDirectionsButton.tintColor = .customRed()
        DropShadowEffect.setupProperties(view: getDirectionsButton, cornerRadius: 16, shadowRadius: 4, widthOffset: 0, heightOffset: 2)
    }

}
