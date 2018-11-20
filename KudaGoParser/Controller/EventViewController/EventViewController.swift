//
//  ViewController.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 14.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit
import Nuke

class EventViewController: UIViewController, CitiesVCDelegate {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var cityButtonRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cityButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var cityButtonBotConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoBotConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imitateNavBarView: UIView!
    @IBOutlet weak var tableTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: IBActions
    
    @IBAction func cityButtonTapped(_ sender: Any) {
        goToCityVC()
    }
    
    // MARK: Properties
    
    var passId: Int?
    var passPlace: String? 
    var passPrice: String?
    var passDate: String?
    
    private var eventsService = EventsService()
    private var page = 1
    private var locationSlug = "msk"
    private var locationName = "Москва"
    private let currentDate = Date().timeIntervalSince1970
    private var visualEffectView: UIVisualEffectView?
    private var refreshControl: UIRefreshControl?
    private var spinner: CustomIndicator?
    private var refreshContent: RefreshContent!
    private var tableViewRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    // MARK: EventViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !Connectivity.isConnectedToInternet() {
            showOfflinePage()
        } else {
            createBlurEffect()
            createLoader()
            setTableViewAppearance()
            setNavBarLogo()
            setPullToRefresh()
            cityButton.setTitleColor(.customRed(), for: .normal)
            
            eventsService.getEvents(currentDate: currentDate, location: locationSlug) {
                self.tableView?.reloadData()
                self.spinner?.stopAnimating()
                self.tableView.isHidden = false
                self.imitateNavBarView.isHidden = false
            }
            eventsService.getCities()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !Connectivity.isConnectedToInternet() {
            showOfflinePage()
        } else {
            if tableView.contentOffset.y > 20 {
                navigationController?.setNavigationBarHidden(false, animated: true)
            } else {
                navigationController?.setNavigationBarHidden(true, animated: false)
            }
            setNavigationBarAppearance()
            refreshContent.startAnimation()
            setNavBarRightItem()
            cityButton.setTitle(locationName, for: .normal)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            if let indexPath  = tableView.indexPathForSelectedRow {
                let dvc = segue.destination  as! DetailViewController
                let id = eventsService.listOfFields[indexPath.row].id
                if let bodyText = eventsService.listOfFields[indexPath.row].bodyText {
                    dvc.eventDetail = bodyText
                } else {
                    dvc.eventDetail = "net"
                }
                let desc = eventsService.listOfFields[indexPath.row].description
                let title = eventsService.listOfFields[indexPath.row].title
                if let latitude = eventsService.listOfCoords[indexPath.row].lat, let longitude = eventsService.listOfCoords[indexPath.row].lon {
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
        
        if segue.identifier == "citySegue" {
            let cvc = segue.destination as! CitiesViewController
            let cities = eventsService.listOfCities
            cvc.cities = cities
            cvc.slug = locationSlug
        }
        
        if let destination = segue.destination as? CitiesViewController{
            destination.delegate = self
        }
    }
    
    func finishPassing(slug: String, name: String) {
        if locationSlug != slug {
            locationSlug = slug
            locationName = name
            clearObject()
            spinner?.startAnimating()
            tableView.isHidden = true
            imitateNavBarView.isHidden = true
            eventsService.getEvents(currentDate: currentDate, location: locationSlug) {
                self.tableView?.reloadData()
                self.spinner?.stopAnimating()
                self.tableView.isHidden = false
                self.imitateNavBarView.isHidden = false
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = tableView.contentOffset.y
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                if offset > 0 && offset < 50 {
                    logoTopConstraint.constant = 36 + (offset * 0.75)
                    logoHeightConstraint.constant = 44 - (offset * 0.6)
                    logoWidthConstraint.constant = 107 - (offset * 1.5)
                    cityButtonRightConstraint.constant = 26 - (offset * 0.5)
                    cityButtonBotConstraint.constant = 11 - (offset * 0.5)
                }
                regularConstraints(offset: offset)
            default:
                if offset > 0 && offset < 84 {
                    navBarHeightConstraint.constant = 84 - offset
                } else {
                    navBarHeightConstraint.constant = 0
                }
                if offset > 0 && offset < 25 {
                    logoBotConstraint.constant = 4 + (offset * 0.1)
                    logoTopConstraint.constant = 36 - (offset * 0.5)
                    logoHeightConstraint.constant = 44 - (offset * 0.6)
                    logoWidthConstraint.constant = 107 - (offset * 1.5)
                    cityButtonRightConstraint.constant = 26 - (offset * 0.5)
                    cityButtonTopConstraint.constant = 43 - (offset * 0.5)
                } else {
                    logoHeightConstraint.constant = 0
                    logoBotConstraint.constant = 0
                    logoTopConstraint.constant = 0
                    logoWidthConstraint.constant = 0
                    cityButtonRightConstraint.constant = 0
                    cityButtonBotConstraint.constant = 0
                    cityButtonTopConstraint.constant = 0
                }
                regularConstraints(offset: offset)
            }
        }
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        tableView.contentOffset.y = 0
    }
}

//MARK: UITableViewDataSource

extension EventViewController: UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsService.listOfFields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        fillData(in: cell, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == eventsService.listOfFields.count - 1 {
            page += 1
            
            eventsService.getPagination(currentDate: currentDate, location: locationSlug, page: page) {
                self.tableView?.reloadData()
            }
        }
    }
}

//MARK: UITableViewDelegate

extension EventViewController: UITableViewDelegate {
    
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
    
}

//MARK: EventViewController extenstion

extension EventViewController {
    
    @objc func performCitySegue() {
        goToCityVC()
    }
    
    @objc func pullToRefresh () {
        
        if !Connectivity.isConnectedToInternet() {
            showOfflinePage()
        } else {
            page = 1
            eventsService.getPullToRefresh(currentDate: currentDate, location: locationSlug) {
                self.tableView?.reloadData()
                self.tableViewRefreshControl.endRefreshing()
            }
        }
    }
    
    //MARK: Private helpers
    
    private func goToCityVC() {
        
        imitateNavBarView.isHidden = true
        self.performSegue(withIdentifier: "citySegue", sender: self)
        
    }
    
    private func createLoader() {
        spinner = CustomIndicator(frame: CGRect(x: 0, y: 0 , width: 32, height: 32), image: UIImage(named: "loader")!)
        spinner?.center = self.view.center
        self.view.addSubview(spinner!)
        spinner?.startAnimating()
        spinner?.backgroundColor = .white
        view.backgroundColor = .white
        //прячем таблицу и навигейшен бар на время загрузки
        tableView.isHidden = true
        imitateNavBarView.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func clearObject() {
        page = 1
        eventsService.listOfFields.removeAll()
        eventsService.listOfDates.removeAll()
        eventsService.listOfAddress.removeAll()
        eventsService.listOfImages.removeAll()
        eventsService.listOfCoords.removeAll()
        eventsService.listOfDetailImages.removeAll()
    }
    
    private func showOfflinePage() -> Void {
        UIView.setAnimationsEnabled(false)
        self.performSegue(withIdentifier: "noInternet", sender: self)
        tableView.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        imitateNavBarView.isHidden = true
    }
    
    private func fillData(in cell: TableViewCell, indexPath: IndexPath) {
        cell.titleLabel.text = eventsService.listOfFields[indexPath.row].title.uppercased()
        cell.descriptionLabel.text = eventsService.listOfFields[indexPath.row].description
        let price = eventsService.listOfFields[indexPath.row].price
        if  price == ""{
            cell.priceLabel.text = "Бесплатно"
        } else {
            cell.priceLabel.text = price
        }
        if let place = eventsService.listOfAddress[indexPath.row].address {
            cell.placeLabel.text = place
            cell.placeStackView.isHidden = false
        } else {
            cell.placeStackView.isHidden = true
        }
        
        let startUnixDate = eventsService.listOfDates[indexPath.row].start
        let endUnixDate = eventsService.listOfDates[indexPath.row].end
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
        
        let imageURL =  eventsService.listOfImages[indexPath.row].picture
        let url = URL(string: imageURL)
        Nuke.loadImage(with: url!, options: ImageLoadingOptions(
            placeholder: UIImage(named: "not_found"),
            transition: .fadeIn(duration: 0.33)
        ), into: cell.picture)
        
    }
    
    private func createBlurEffect() {
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        visualEffectView?.frame = (navigationController?.navigationBar.bounds.insetBy(dx: 0, dy: -30).offsetBy(dx: 0, dy: -30))!
        self.navigationController?.navigationBar.addSubview(visualEffectView!)
        self.navigationController?.navigationBar.sendSubviewToBack(visualEffectView!)
    }
    
    private func setNavigationBarAppearance() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    private func setNavBarRightItem() {
        let buttonItem = UIButton(type: .system)
        let view = UIView()
        buttonItem.setTitle(locationName, for: .normal)
        buttonItem.setImage(UIImage(named: "right_bar_button"), for: .normal)
        buttonItem.semanticContentAttribute = .forceRightToLeft
        buttonItem.titleEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 0)
        buttonItem.tintColor = .customRed()
        buttonItem.titleLabel?.font = UIFont(name: "SFProText-Semibold", size: 17)
        buttonItem.addTarget(self, action: #selector(performCitySegue), for: .touchUpInside)
        buttonItem.sizeToFit()
        view.addSubview(buttonItem)
        view.frame = buttonItem.bounds
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: view)
    }
    
    private func setNavBarLogo() {
        var logo = UIImage(named: "kudago_logo")
        logo = logo?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: logo, style:.plain, target: nil, action: nil)
    }
    
    private func setPullToRefresh() {
        if let objOfRefreshView = Bundle.main.loadNibNamed("RefreshContent", owner: self, options: nil)?.first as? RefreshContent {
            refreshContent = objOfRefreshView
            refreshContent.frame = tableViewRefreshControl.frame
            tableViewRefreshControl.addSubview(refreshContent)
        }
        tableView.refreshControl = tableViewRefreshControl
    }
    
    private func setTableViewAppearance() {
        tableView.backgroundColor = .white
        tableTitle.text = "Куда сходить"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func regularConstraints(offset: CGFloat ) {
        
        if offset > 20 {
            navigationController?.setNavigationBarHidden(false, animated: false)
        } else {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
        
        if offset <= 0 {
            navBarHeightConstraint.constant = 84
            logoTopConstraint.constant = 36
            logoBotConstraint.constant = 4
            logoWidthConstraint.constant = 107
            logoHeightConstraint.constant = 44
            cityButtonRightConstraint.constant = 26
            cityButtonBotConstraint.constant = 11
            cityButtonTopConstraint.constant = 43
        }
    }
}




