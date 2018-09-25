//
//  CitiesViewController.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 04.06.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

protocol CitiesVCDelegate {
    func finishPassing(slug: String, name: String)
}

class CitiesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Properties
    
    var cities = [Cities]()
    var slug: String?
    var cityName: String?
    var delegate: CitiesVCDelegate?
    
    //MARK: CitiesViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Выбор города"
        tableView.delegate = self
        tableView.dataSource = self
        setBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarAppearance()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let slug = slug, let cityName = cityName {
            delegate?.finishPassing(slug: slug, name: cityName)
        }
    }
    
    //MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        fillData(in: cell!, indexPath: indexPath)
        
        return cell!
    }
    
    //MARK: UItableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        slug = cities[indexPath.row].slug
        cityName = cities[indexPath.row].name
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
}

//MARK: CitiesViewController extenstion

extension CitiesViewController {
    
    //MARK: Private helpers
    
    private func setBackButton() {
        let backButton = UIBarButtonItem(title: "Закрыть", style: UIBarButtonItem.Style.done, target: nil, action: nil)
        backButton.tintColor = .customRed()
        backButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProText-Regular", size: 17)!], for: .normal)
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        navigationController?.navigationBar.backIndicatorImage = UIImage()
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage()
    }
    
    private func setNavigationBarAppearance() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 0.82)
    }
    
    private func fillData(in cell: UITableViewCell, indexPath: IndexPath) {
        
        cell.textLabel?.text = cities[indexPath.row].name
        cell.tintColor = .customRed()
        
        if slug == cities[indexPath.row].slug {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.accessoryType = .checkmark
        }
    }
}
