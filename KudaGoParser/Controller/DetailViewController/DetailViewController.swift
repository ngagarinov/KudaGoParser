//
//  DetailViewController.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 24.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UITableViewController, MKMapViewDelegate {

    var lat: Double?
    var lon: Double?
    var eventId: Int?
    var eventPlace: String?
    var eventPrice: String?
    var eventDate: String?
    var eventDesc: String?
    var eventTitle: String?
    var eventDetail: String?
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    var pin:AnnotationPin!
    
    var parseManager = ParseManager()
    private var roundButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableViewAppearance()
        
        parseManager.parseKudaGo(request: parseType.detail(id: eventId!).request, parse: .images) {_ in
            self.tableView?.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createFloatingButton()
        setStatusBar()

    }

    override func viewWillDisappear(_ animated: Bool) {
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.isNavigationBarHidden = false
        UIApplication.shared.statusBarStyle = .default
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DetailViewCell
        
        let countOfImages = parseManager.listOfDetailImages.count
        cell.pageControl.numberOfPages = countOfImages
        
        for index in 0..<countOfImages {
            
            frame.origin.x = cell.scrollView.frame.size.width * CGFloat(index)
            frame.size = cell.scrollView.frame.size
            
            let imgView = UIImageView(frame: frame)
            imgView.contentMode = .scaleAspectFill
            imgView.clipsToBounds = true
            
            let url = URL(string:  parseManager.listOfDetailImages[index].picture)
            imgView.sd_setImage(with: url )
            cell.scrollView.addSubview(imgView)
        }
        
        cell.scrollView.contentSize = CGSize(width: (cell.scrollView.frame.size.width * CGFloat(countOfImages)), height: cell.scrollView.frame.size.height)
        
        cell.titleLabel.text = eventTitle?.uppercased()
        cell.descriptionLabel.text = eventDesc
        cell.detailLabel.text = eventDetail
        if let place = eventPlace {
            cell.placeLabel.text = place
        } else {
            cell.placeStackView.isHidden = true
        }
        cell.dateLabel.text = eventDate
        cell.priceLabel.text = eventPrice
        
        if let latitude = lat, let longitude = lon {
            cell.mapView.delegate = self
            let locationCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            pin = AnnotationPin(coordinate: locationCoordinates)
            let zoomSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: locationCoordinates, span: zoomSpan)
            cell.mapView.setRegion(region, animated: true)
            cell.mapView.addAnnotation(pin)
        } else {
            cell.mapView.isHidden = true
        }

        return cell
    }
    
    func createFloatingButton() {

        roundButton = UIButton(type: .custom)
        roundButton.translatesAutoresizingMaskIntoConstraints = false
        roundButton.backgroundColor = .white
        roundButton.setImage(UIImage(named:"back"), for: .normal)
        roundButton.addTarget(self, action: #selector(backAction), for: UIControlEvents.touchUpInside)
        roundButton.layer.cornerRadius = 16
        roundButton.layer.shadowColor = UIColor.black.cgColor
        roundButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        roundButton.layer.masksToBounds = false
        roundButton.layer.shadowRadius = 4.0
        roundButton.layer.shadowOpacity = 0.1
        view.addSubview(roundButton)
        if #available(iOS 11.0, *) {
            roundButton.leadingAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
            roundButton.topAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.topAnchor, constant: 7).isActive = true
        } else {
            roundButton.leadingAnchor.constraint(equalTo: tableView.layoutMarginsGuide.leadingAnchor, constant: 8).isActive = true
            roundButton.topAnchor.constraint(equalTo: tableView.layoutMarginsGuide.topAnchor, constant: 7).isActive = true
        }
        roundButton.widthAnchor.constraint(equalToConstant: 48).isActive = true
        roundButton.heightAnchor.constraint(equalToConstant: 32).isActive = true

    }
    
    func setStatusBar() {
        if let statusbar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusbar.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4)
        }
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurEffectView)
        blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        blurEffectView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        blurEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        if #available(iOS 11.0, *) {
            blurEffectView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            blurEffectView.bottomAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        }
    }
    
    func setTableViewAppearance() {
        tableView?.estimatedRowHeight = 231
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
    }
    
    @objc func backAction() {
        navigationController?.popViewController(animated: false)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: pin, reuseIdentifier: "pinMap")
        annotationView.image = UIImage(named: "pin_map")
        
        return annotationView
    }
    
    
}


