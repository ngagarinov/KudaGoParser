//
//  DetailViewCell.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 24.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit
import MapKit

final class DetailViewCell: UITableViewCell,UIScrollViewDelegate {
    
    private enum Constants {
        static let cornerRadius: CGFloat = 16
        static let shadowRadius: CGFloat = 4
        static let heightOffset: Double = 2
    }
    
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
        
        pageControl.superview?.bringSubviewToFront(pageControl)
        scrollView.delegate = self
        pageControl.isHidden = true
        
        setupGetDirectionsButtonAppearance()
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
    }
    
    func setupGetDirectionsButtonAppearance() {
        getDirectionsButton.superview?.bringSubviewToFront(getDirectionsButton)
        getDirectionsButton.backgroundColor = .white
        getDirectionsButton.setTitle("Проложить маршрут", for: .normal)
        getDirectionsButton.tintColor = .customRed()
        getDirectionsButton.setupShadowEffect(cornerRadius: Constants.cornerRadius, shadowRadius: Constants.shadowRadius, widthOffset: 0, heightOffset: Constants.heightOffset)
    }
    
}
