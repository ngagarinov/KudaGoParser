//
//  ViewController.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 14.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit
import Nuke

class EventViewController: UIViewController, ToEventVCDelegate {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var tableTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: IBActions
    
    @IBAction func cityButtonTapped(_ sender: Any) {
        goToCityVC()
    }
    
    // MARK: Properties
    
    private lazy var adapter = EventTableViewAdapter(tableView: tableView)
    
    private var eventsService = EventsService()
    private let currentDate = Date().timeIntervalSince1970//
    private var refreshControl: UIRefreshControl?
    private var spinner: CustomIndicator?
    private var cityBarButtonItem: UIButton!
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
        
        createLoader()
        setTableViewAppearance()
        setNavBarLogo()
        setPullToRefresh()
        setNavBarRightItem()
        createBlurEffect()
        adapter.eventViewController = self
        
        eventsService.getEvents(currentDate: currentDate, location: adapter.locationSlug) { result in
            switch result {
            case .data(let event):
                self.adapter.configure(with: event)
                self.spinner?.stopAnimating()
                self.tableView.isHidden = false
                self.navigationController?.setNavigationBarHidden(false, animated: false)
            case .error:
                self.showOfflinePage()
            }
        }
        
        eventsService.getCities() { result in
            switch result {
            case .data(let cities):
                self.adapter.configure(with: cities)
            case .error:
                self.showOfflinePage()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshContent.startAnimation()
    }
    
    func finishPassing(slug: String, name: String) {
        if adapter.locationSlug != slug {
            adapter.locationSlug = slug
            adapter.locationName = name
            setNavBarRightItem()
            spinner?.startAnimating()
            tableView.isHidden = true
            eventsService.getEvents(currentDate: currentDate, location: adapter.locationSlug) { result in
                switch result {
                case .data(let event):
                    self.adapter.configure(with: event)
                    self.spinner?.stopAnimating()
                    self.tableView.isHidden = false
                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                case .error:
                    self.showOfflinePage()
                }
            }
             self.tableView.contentOffset.y = -88
        }
    }
}

//MARK: EventViewController extenstion

extension EventViewController {
    
    @objc func goToCityVC() {
        let controller: CitiesViewController = CitiesViewController.loadFromStoryboard()
        controller.cities = adapter.cities
        controller.slug = adapter.locationSlug
        controller.delegate = self
        present(controller, animated: true)
    }
    
    @objc func pullToRefresh () {
        
        adapter.page = 1
        eventsService.getPullToRefresh(currentDate: currentDate, location: adapter.locationSlug) { result in
            switch result {
            case .data(let event):
                self.adapter.configure(with: event)
                self.tableViewRefreshControl.endRefreshing()
            case .error:
                self.showOfflinePage()
            }
        }
    }
    
    //MARK: Private helpers
    
    private func createLoader() {
        spinner = CustomIndicator(frame: CGRect(x: 0, y: 0 , width: 32, height: 32), image: UIImage(named: "loader")!)
        spinner?.center = self.view.center
        self.view.addSubview(spinner!)
        spinner?.startAnimating()
        spinner?.backgroundColor = .white
        view.backgroundColor = .white
        //прячем таблицу и навигейшен бар на время загрузки
        tableView.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func showOfflinePage() -> Void {
        UIView.setAnimationsEnabled(false)
        let controller: NoConnectionViewController = NoConnectionViewController.loadFromStoryboard()
        navigationController?.pushViewController(controller, animated: true)
        tableView.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func createBlurEffect() {
        
        guard let navigationBar = navigationController?.navigationBar else { return }

        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        let visualEffectView   = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        var bounds = navigationBar.bounds
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        bounds.size.height += statusBarHeight
        bounds.origin.y -= statusBarHeight
        visualEffectView.isUserInteractionEnabled = false
        visualEffectView.frame = bounds
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navigationBar.addSubview(visualEffectView)
        visualEffectView.layer.zPosition = -1
    }
    
    private func setNavBarRightItem() {
        cityBarButtonItem = UIButton(type: .system)
        let view = UIView()
        cityBarButtonItem.setTitle(adapter.locationName, for: .normal)
        cityBarButtonItem.setImage(UIImage(named: "right_bar_button"), for: .normal)
        cityBarButtonItem.semanticContentAttribute = .forceRightToLeft
        cityBarButtonItem.titleEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 0)
        cityBarButtonItem.tintColor = .customRed()
        cityBarButtonItem.titleLabel?.font = UIFont(name: "SFProText-Semibold", size: 17)
        cityBarButtonItem.titleLabel?.contentMode = .scaleAspectFill
        cityBarButtonItem.addTarget(self, action: #selector(goToCityVC), for: .touchUpInside)
        cityBarButtonItem.sizeToFit()
        view.addSubview(cityBarButtonItem)
        view.frame = cityBarButtonItem.bounds
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
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
}




