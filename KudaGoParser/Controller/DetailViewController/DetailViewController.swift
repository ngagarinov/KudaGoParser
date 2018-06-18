//
//  DetailViewController.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 24.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit
import MapKit
import Nuke

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
    
    private var popRecognizer: InteractivePopRecognizer?
    private var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    private var pin: AnnotationPin!
    private var parseManager = ParseManager()
    private var floatButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableViewAppearance()
        setInteractiveRecognizer()
        parseManager.getImages(id: eventId! ) {
            self.tableView?.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createFloatingButton()
        setStatusBar()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DetailViewCell
        
        fillData(in: cell)
        
        return cell
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: pin, reuseIdentifier: "pinMap")
        annotationView.image = UIImage(named: "pin_map")
        
        return annotationView
    }
    
}

extension DetailViewController {
    
    @objc func getDirectionsAction() {
        if let latitude = lat, let longitude = lon {
            let locationCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let placemark = MKPlacemark(
                coordinate: locationCoordinates,
                addressDictionary: nil
            )
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = eventPlace
            let options = [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ]
            MKMapItem.openMaps(with: [mapItem], launchOptions: options)
        }
    }
    
    @objc func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setTableViewAppearance() {
        tableView?.estimatedRowHeight = 231
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
    }
    
    private func setStatusBar() {
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
    
    
    private func createFloatingButton() {
        floatButton = UIButton(type: .custom)
        floatButton.translatesAutoresizingMaskIntoConstraints = false
        floatButton.backgroundColor = .white
        floatButton.setImage(UIImage(named:"back"), for: .normal)
        floatButton.addTarget(self, action: #selector(backAction), for: UIControlEvents.touchUpInside)
        DropShadowEffect.setupProperties(view: floatButton, cornerRadius: 16, shadowRadius: 4, widthOffset: 0, heightOffset: 2)
        view.addSubview(floatButton)
        if #available(iOS 11.0, *) {
            floatButton.leadingAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
            floatButton.topAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.topAnchor, constant: 7).isActive = true
        } else {
            floatButton.leadingAnchor.constraint(equalTo: tableView.layoutMarginsGuide.leadingAnchor, constant: 8).isActive = true
            floatButton.topAnchor.constraint(equalTo: tableView.layoutMarginsGuide.topAnchor, constant: 7).isActive = true
        }
        floatButton.widthAnchor.constraint(equalToConstant: 48).isActive = true
        floatButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    private func fillData(in cell: DetailViewCell) {
        
        // Создаем карусель картинок
        let countOfImages = parseManager.listOfDetailImages.count
        cell.pageControl.numberOfPages = countOfImages
        for index in 0..<countOfImages {
            frame.origin.x = cell.scrollView.frame.size.width * CGFloat(index)
            frame.size = cell.scrollView.frame.size
            
            let imgView = UIImageView(frame: frame)
            imgView.contentMode = .scaleAspectFill
            imgView.clipsToBounds = true
            
            let url = URL(string:  parseManager.listOfDetailImages[index].picture)
            Nuke.loadImage(with: url!, options: ImageLoadingOptions(
                placeholder: UIImage(named: "not_found"),
                transition: .fadeIn(duration: 0.33)), into: imgView)
            cell.scrollView.addSubview(imgView)
        }
        cell.scrollView.contentSize = CGSize(width: (cell.scrollView.frame.size.width * CGFloat(countOfImages)), height: cell.scrollView.frame.size.height)
        
        // Отображаем данные, полученные с предыдущего VC
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
        
        // Отображаем место на карте, если место вернулось с API
        if let latitude = lat, let longitude = lon {
            cell.getDirectionsButton.addTarget(self, action: #selector(getDirectionsAction), for: UIControlEvents.touchUpInside)
            cell.mapView.delegate = self
            let locationCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            pin = AnnotationPin(coordinate: locationCoordinates)
            let zoomSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: locationCoordinates, span: zoomSpan)
            cell.mapView.setRegion(region, animated: true)
            cell.mapView.addAnnotation(pin)
        } else {
            cell.mapView.isHidden = true
            cell.getDirectionsButton.isHidden = true
        }
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
}


