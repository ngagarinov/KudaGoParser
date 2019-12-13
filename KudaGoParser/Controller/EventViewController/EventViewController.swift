//
//  ViewController.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 14.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit
import Nuke
import SwiftMessages

final class EventViewController: UIViewController, ToEventVCDelegate {
    
    // MARK: - Constants
    
    private enum Constants {
        static let messageViewEdgeInset: CGFloat = 20
        static let tableViewContentOffset: CGFloat = -88
        static let errorNotificationSeconds: TimeInterval = 5
        static let cityButtonLeftInset: CGFloat = -6
        static let estimatedHeight: CGFloat = 100
    }
    
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
    private let currentDate = Date().timeIntervalSince1970
    private var refreshControl: UIRefreshControl?
    private var cityBarButtonItem: UIButton!
    private var refreshContent: RefreshContent!
    private var tableViewRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    lazy private var spinner : SYActivityIndicatorView = {
        return SYActivityIndicatorView(image: nil)
    }()
    lazy private var messageView: MessageView = {
        let messageView = MessageView.viewFromNib(layout: .messageView)
        messageView.configureTheme(.error)
        messageView.configureDropShadow()
        messageView.iconLabel?.isHidden = true
        messageView.button?.isHidden = true
        messageView.configureContent(title: "Ошибка", body: "Проверьте соединение с интернетом")
        messageView.layoutMarginAdditions = UIEdgeInsets(top: Constants.messageViewEdgeInset,
                                                         left: Constants.messageViewEdgeInset,
                                                         bottom: Constants.messageViewEdgeInset,
                                                         right: Constants.messageViewEdgeInset)
        return messageView
    }()
    
    // MARK: - EventViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createLoader()
        setTableViewAppearance()
        setNavBarLogo()
        setPullToRefresh()
        setNavBarRightItem()
        createBlurEffect()
        getEventsRequest()
        getCitiesRequest()
        adapter.eventViewController = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        messageView.isHidden = true
    }
    
    func finishPassing(slug: String, name: String) {
        if adapter.locationSlug != slug {
            adapter.locationSlug = slug
            adapter.locationName = name
            setNavBarRightItem()
            spinner.startAnimating()
            tableView.isHidden = true
            getEventsRequest()
            self.tableView.contentOffset.y = Constants.tableViewContentOffset
        }
    }
}

//MARK: - Private EventViewController extenstion

private extension EventViewController {
    
    @objc func goToCityVC() {
        let controller: CitiesViewController = CitiesViewController.loadFromStoryboard()
        controller.cities = adapter.cities
        controller.slug = adapter.locationSlug
        controller.delegate = self
        present(controller, animated: true)
    }
    
    @objc func pullToRefresh () {
        
        refreshContent.startAnimation()
        adapter.page = 1
        eventsService.getPullToRefresh(currentDate: currentDate, location: adapter.locationSlug) { result in
            switch result {
            case .data(let event):
                self.adapter.configure(with: event)
                self.refreshContent.stopAnimation()
                self.tableViewRefreshControl.endRefreshing()
            case .error:
                self.showErrorNotification()
                self.refreshContent.stopAnimation()
                self.tableViewRefreshControl.endRefreshing()
            }
        }
        getCitiesRequest()
    }
    
    func getEventsRequest() {
        eventsService.getEvents(currentDate: currentDate, location: adapter.locationSlug) { result in
            switch result {
            case .data(let event):
                self.adapter.configure(with: event)
                self.spinner.stopAnimating()
                self.tableView.isHidden = false
                self.navigationController?.setNavigationBarHidden(false, animated: false)
            case .error:
                self.showErrorNotification()
                self.spinner.stopAnimating()
                self.tableView.isHidden = false
                self.navigationController?.setNavigationBarHidden(false, animated: false)
            }
        }
    }
    
    func getCitiesRequest() {
        eventsService.getCities() { result in
            switch result {
            case .data(let cities):
                self.adapter.configure(with: cities)
            case .error:
                print("error")
            }
        }
    }
    
    func createLoader() {
        spinner.center = self.view.center
        self.view.addSubview(spinner)
        spinner.center = self.view.center
        spinner.startAnimating()
        view.backgroundColor = .white
        //прячем таблицу и навигейшен бар на время загрузки
        tableView.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func showErrorNotification()  {
        messageView.isHidden = false
        var config = SwiftMessages.Config()
        config.duration = .seconds(seconds: Constants.errorNotificationSeconds)
        SwiftMessages.show(config: config, view: messageView)
    }
    
    func createBlurEffect() {
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
    
    func setNavBarRightItem() {
        cityBarButtonItem = UIButton(type: .system)
        let view = UIView()
        cityBarButtonItem.setTitle(adapter.locationName, for: .normal)
        cityBarButtonItem.setImage(UIImage(named: "right_bar_button"), for: .normal)
        cityBarButtonItem.semanticContentAttribute = .forceRightToLeft
        cityBarButtonItem.titleEdgeInsets = UIEdgeInsets(top: 0, left: Constants.cityButtonLeftInset, bottom: 0, right: 0)
        cityBarButtonItem.tintColor = .customRed()
        cityBarButtonItem.titleLabel?.font = UIFont(name: "SFProText-Semibold", size: 17)
        cityBarButtonItem.titleLabel?.contentMode = .scaleAspectFill
        cityBarButtonItem.addTarget(self, action: #selector(goToCityVC), for: .touchUpInside)
        cityBarButtonItem.sizeToFit()
        view.addSubview(cityBarButtonItem)
        view.frame = cityBarButtonItem.bounds
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: view)
    }
    
    func setNavBarLogo() {
        var logo = UIImage(named: "kudago_logo")
        logo = logo?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: logo, style:.plain, target: nil, action: nil)
    }
    
    func setPullToRefresh() {
        if let objOfRefreshView = Bundle.main.loadNibNamed("RefreshContent", owner: self, options: nil)?.first as? RefreshContent {
            refreshContent = objOfRefreshView
            refreshContent.hidesLoader()
            refreshContent.frame = tableViewRefreshControl.frame
            tableViewRefreshControl.addSubview(refreshContent)
        }
        tableView.refreshControl = tableViewRefreshControl
    }
    
    func setTableViewAppearance() {
        tableView.backgroundColor = .white
        tableTitle.text = "Куда сходить"
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = Constants.estimatedHeight
        tableView.rowHeight = UITableView.automaticDimension
    }
}




