//
//  ViewController.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 14.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit
import SDWebImage

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var parseManager = ParseManager()
    let currentDate = Date().timeIntervalSince1970
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBarAppearance()
        setTableViewAppearance()
        
        parseManager.parseKudaGo(request: parseType.events(currentDate: currentDate).request, parse: .event) {_ in
            self.tableView?.reloadData()
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
        cell.descriptionLabel.text = parseManager.listOfFields[indexPath.row].description.html2String
        let price = parseManager.listOfFields[indexPath.row].price
        if  price == ""{
            cell.priceLabel.text = "Бесплатно"
        } else {
            cell.priceLabel.text = price
        }
        if let place = parseManager.listOfAddress[indexPath.row].address {
            cell.placeLabel.text = place
        } else {
            cell.placeStackView.isHidden = true 
        }

//cell.backgroundColor = .white
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
        
        cell.picture.sd_setImage(with: url) 
        // Nuke.loadImage(with: url!, into: cell.imageVi)
        //    cell.picture.image = #imageLiteral(resourceName: "kudagologo")
        
//        Alamofire.request(url!).responseImage { response in
//            debugPrint(response)
//
//            if let image = response.result.value {
//                cell.imageVi.image = image
//            }
//        }
        
        cell.clipsToBounds = false
        
        //Set containerView padding
  
        
        //Make cell selection invisible
        cell.selectionStyle = .none
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var page = 1
        if indexPath.row == parseManager.listOfFields.count - 1 {
            page += 1
            
            parseManager.parseKudaGo(request: parseType.pages(page: page, currentDate: currentDate).request, parse: .event) {_ in
                self.tableView?.reloadData()
            }
            
        }
    }
    
    func setNavigationBarAppearance() {
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        var logo = UIImage(named: "kudagologo")
        logo = logo?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: logo, style:.plain, target: nil, action: nil)
    }
    
    func setTableViewAppearance() {
        tableView.backgroundColor = .white
        tableTitle.text = "Куда сходить"
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.separatorInset = .zero
        // tableView.backgroundColor = UIColor.white
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }


}

