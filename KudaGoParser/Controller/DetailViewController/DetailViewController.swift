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

final class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    // MARK: - Constants
    
    private enum Constants {
        static let estimatedHeight: CGFloat = 231
        static let cornerRadius: CGFloat = 16
        static let shadowRadius: CGFloat = 4
        static let heightOffset: Double = 2
        static let leadingAnchor: CGFloat = 8
        static let topAnchor: CGFloat = 7
        static let widthAnchor: CGFloat = 48
        static let heightAnchor: CGFloat = 32
        static let latitudeDelta: CLLocationDegrees = 0.01
        static let longitudeDelta: CLLocationDegrees = 0.01
    }
    
    //MARK: - IBOultets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var lat: Double?
    var lon: Double?
    var eventId: Int?
    var eventPlace: String?
    var eventPrice: String?
    var eventDate: String?
    var eventDesc: String?
    var eventTitle: String?
    var eventDetail: String?
    
    private var detailImages: [Image]?
    private var popRecognizer: InteractivePopRecognizer?
    private var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    private var pin: AnnotationPin!
    private var eventsService = EventsService()
    private var floatButton = UIButton()
    
    // MARK: - DetailViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        setTableViewAppearance()
        setInteractiveRecognizer()
        createFloatingButton()
        setStatusBar()
    
        tableView.register(UINib(nibName: "DetailViewCell", bundle: nil), forCellReuseIdentifier: "Cell")

        eventsService.getImages(id: eventId! ) { result in
            switch result {
            case .data(let images):
                self.detailImages = images
                self.tableView?.reloadData()
            case .error:
                print("error")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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

//MARK: - Private DetailViewController extenstion

private extension DetailViewController {
    
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
    
    func setTableViewAppearance() {
        tableView?.estimatedRowHeight = Constants.estimatedHeight
        tableView?.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
    }
    
    func setStatusBar() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurEffectView)
        blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        blurEffectView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        blurEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        if #available(iOS 11.0, *) {
            blurEffectView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            blurEffectView.bottomAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        }
    }
    
    func createFloatingButton() {
        floatButton = UIButton(type: .custom)
        floatButton.translatesAutoresizingMaskIntoConstraints = false
        floatButton.backgroundColor = .white
        floatButton.setImage(UIImage(named:"back"), for: .normal)
        floatButton.addTarget(self, action: #selector(backAction), for: UIControl.Event.touchUpInside)
        floatButton.setupShadowEffect(cornerRadius: Constants.cornerRadius, shadowRadius: Constants.shadowRadius, widthOffset: 0, heightOffset: Constants.heightOffset)
        view.addSubview(floatButton)
        if #available(iOS 11.0, *) {
            floatButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.leadingAnchor).isActive = true
            floatButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.topAnchor).isActive = true
        } else {
            floatButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: Constants.leadingAnchor).isActive = true
            floatButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: Constants.topAnchor).isActive = true
        }
        floatButton.widthAnchor.constraint(equalToConstant: Constants.widthAnchor).isActive = true
        floatButton.heightAnchor.constraint(equalToConstant: Constants.heightAnchor).isActive = true
    }
    
    func fillData(in cell: DetailViewCell) {
        // Создаем карусель картинок
        if let detailImages = self.detailImages {
            let countOfImages = detailImages.count
            cell.pageControl.numberOfPages = countOfImages
            cell.pageControl.isHidden = false
            for index in 0..<countOfImages {
                frame.origin.x = cell.scrollView.frame.size.width * CGFloat(index)
                frame.size = cell.scrollView.frame.size
                
                let imgView = UIImageView(frame: frame)
                imgView.contentMode = .scaleAspectFill
                imgView.clipsToBounds = true
                let imageStringUrl = detailImages[index].thumbnails.picture
                let placeholder = UIImage(named: "placeholder")
                imgView.loadImage(with: imageStringUrl, placeholder: placeholder)
                
                cell.scrollView.addSubview(imgView)
            }
            cell.scrollView.contentSize = CGSize(width: (cell.scrollView.frame.size.width * CGFloat(countOfImages)), height: cell.scrollView.frame.size.height)
        }
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
            cell.getDirectionsButton.addTarget(self, action: #selector(getDirectionsAction), for: UIControl.Event.touchUpInside)
            cell.mapView.delegate = self
            let locationCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            pin = AnnotationPin(coordinate: locationCoordinates)
            let zoomSpan = MKCoordinateSpan(latitudeDelta: Constants.latitudeDelta, longitudeDelta: Constants.longitudeDelta)
            let region = MKCoordinateRegion(center: locationCoordinates, span: zoomSpan)
            cell.mapView.setRegion(region, animated: true)
            cell.mapView.addAnnotation(pin)
        } else {
            cell.mapView.isHidden = true
            cell.getDirectionsButton.isHidden = true
        }
    }
    
    func setInteractiveRecognizer() {
        guard let controller = navigationController else {
            return
        }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
}


