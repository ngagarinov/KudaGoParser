//
//  ViewController.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 14.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import Nuke

class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}


class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var passId: Int?
    var passPlace: String? 
    var passPrice: String?
    var passDate: String?
    private var page = 1
    var parseManager = ParseManager()
    let currentDate = Date().timeIntervalSince1970
    
    var refreshControl: UIRefreshControl?
    
    var spinner: MyIndicator?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !Connectivity.isConnectedToInternet() {
            showOfflinePage()
        } else {
            
            createLoader()
            setTableViewAppearance()
            
            //        refreshControl = UIRefreshControl()
            //refreshControl = createRefreshControl()
            //loadRefresh()
            //        refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
            //        tableView.addSubview(refreshControl!)
            
            
            parseManager.parseKudaGo(request: parseType.events(currentDate: currentDate).request, parse: .event) {_ in
                self.tableView?.reloadData()
                self.spinner?.stopAnimating()
                self.tableView.isHidden = false
                //self.navigationController?.isNavigationBarHidden = false
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                self.setNavigationBarAppearance()
                
            }
        }
    }
    
    private func showOfflinePage() -> Void {
        UIView.setAnimationsEnabled(false)
        self.performSegue(withIdentifier: "noInternet", sender: self)
       // UIView.setAnimationsEnabled(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.setNavigationBarHidden(false, animated: true)
        //setNavigationBarAppearance()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       // navigationController?.setNavigationBarHidden(true, animated: true)
    }

    
    func createLoader() {
        spinner = MyIndicator(frame: CGRect(x: 0, y: 0 , width: 32, height: 32), image: UIImage(named: "loader")!)
        spinner?.center = self.view.center
        self.view.addSubview(spinner!)
        spinner?.startAnimating()
        spinner?.backgroundColor = .white
        view.backgroundColor = .white
        tableView.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func createRefreshControl() -> UIRefreshControl {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        refreshControl?.backgroundColor = UIColor.clear
        refreshControl?.tintColor = UIColor.clear
        return refreshControl!
    }
    
    func loadRefresh() {
        
        let refreshContent = Bundle.main.loadNibNamed("RefreshContent", owner: self, options: nil)
        let customRefreshView = refreshContent![0] as! UIView
        customRefreshView.frame = (refreshControl?.bounds)!
        
        let customImage = customRefreshView.viewWithTag(1) as! UIImageView
        
//        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
//        rotateAnimation.fromValue = 0.0
//        rotateAnimation.toValue = CGFloat(.pi * 2.0)
//        rotateAnimation.duration = 1.5
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.repeatCount = Float.greatestFiniteMagnitude;
        
        customImage.layer.add(rotation, forKey: nil)
        
        refreshControl?.addSubview(customRefreshView)
        
    }
    
    @objc func pullToRefresh () {
//        page = 1
//        parseManager.listOfFields.removeAll()
//        parseManager.listOfDates.removeAll()
//        parseManager.listOfAddress.removeAll()
//        parseManager.listOfImages.removeAll()
//        parseManager.listOfStart.removeAll()
//        parseManager.listOfEnd.removeAll()
        parseManager.parseKudaGo(request: parseType.events(currentDate: currentDate).request, parse: .event) {_ in
            self.tableView?.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return parseManager.listOfFields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        fillDataIn(cell, indexPath: indexPath)
        
        return cell
    }
    
    func fillDataIn(_ cell: TableViewCell, indexPath: IndexPath) {

        cell.titleLabel.text = parseManager.listOfFields[indexPath.row].title.uppercased()
        cell.descriptionLabel.text = parseManager.listOfFields[indexPath.row].description
        let price = parseManager.listOfFields[indexPath.row].price
        if  price == ""{
            cell.priceLabel.text = "Бесплатно"
        } else {
            cell.priceLabel.text = price 
        }
        if let place = parseManager.listOfAddress[indexPath.row].address {
            cell.placeLabel.text = place
            cell.placeStackView.isHidden = false
        } else {
            cell.placeLabel.text = " MESTA NET NO VI DERJItES'"
            cell.placeStackView.isHidden = true
        }

        let startUnixDate = parseManager.listOfDates[indexPath.row].start
        let endUnixDate = parseManager.listOfDates[indexPath.row].end
        let startDate = Date(timeIntervalSince1970: startUnixDate )
        let endDate = Date(timeIntervalSince1970: endUnixDate)
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "GMT")!
        let compareMonths = calendar.isDate(startDate, equalTo: endDate, toGranularity: .month)
        let compareDays = calendar.isDate(startDate, equalTo: endDate, toGranularity: .day)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMMd")
        if compareMonths {
            if compareDays {
                cell.dateLabel.text = dateFormatter.string(from: endDate)
            } else {
                let startDay = calendar.component(.day, from: startDate)
                cell.dateLabel.text = "\(startDay)-" + dateFormatter.string(from: endDate)
            }
        } else {
            cell.dateLabel.text = dateFormatter.string(from: startDate) + " - " + dateFormatter.string(from: endDate)
        }
        let imageURL =  parseManager.listOfImages[indexPath.row].picture
        let url = URL(string: imageURL)
        Nuke.Manager.shared.loadImage(with: url!, options: ImageLoadingOptions(
            placeholder: UIImage(named: "placeholder"),
            transition: .fadeIn(0.33)
        ), into: cell.picture)

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == parseManager.listOfFields.count - 1 {
            page += 1
            
            parseManager.parseKudaGo(request: parseType.pages(page: page, currentDate: currentDate).request, parse: .event) {_ in
                self.tableView?.reloadData()
            }
        }
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
        
        passPrice = cell.priceLabel.text
        passDate = cell.dateLabel.text
        if !cell.placeStackView.isHidden {
        passPlace = cell.placeLabel.text
        } else {
            passPlace = nil
        }

        performSegue(withIdentifier: "detailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "detailSegue" {
            if let indexPath  = tableView.indexPathForSelectedRow {
                
                let dvc = segue.destination  as! DetailViewController
                
                let id = parseManager.listOfFields[indexPath.row].id
                if let bodyText = parseManager.listOfFields[indexPath.row].bodyText {
                    dvc.eventDetail = bodyText
                } else {
                    dvc.eventDetail = "net"
                }
                let desc = parseManager.listOfFields[indexPath.row].description
                let title = parseManager.listOfFields[indexPath.row].title
                if let latitude = parseManager.listOfCoords[indexPath.row].lat, let longitude = parseManager.listOfCoords[indexPath.row].lon {
                    dvc.lat = latitude
                    dvc.lon = longitude
                } else {
                    dvc.lat = nil
                    dvc.lon = nil
                }
                
                dvc.eventId = id
                dvc.eventTitle = title
                dvc.eventDesc = desc
                dvc.eventPrice = passPrice
                dvc.eventDate = passDate
                dvc.eventPlace = passPlace
            }
        }
    }
    
    func setNavigationBarAppearance() {
//        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
//        let visualEffectView   = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//        visualEffectView.frame =  (navigationController?.navigationBar.bounds.insetBy(dx: 0, dy: -(statusBarHeight)).offsetBy(dx: 0, dy: -(statusBarHeight)))!
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
//        self.navigationController?.navigationBar.addSubview(visualEffectView)
//        self.navigationController?.navigationBar.sendSubview(toBack: visualEffectView)
        
        var logo = UIImage(named: "kudagologo")
        logo = logo?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: logo, style:.plain, target: nil, action: nil)
    }
    
    func setTableViewAppearance() {
        tableView.backgroundColor = .white
        tableTitle.text = "Куда сходить"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
}
