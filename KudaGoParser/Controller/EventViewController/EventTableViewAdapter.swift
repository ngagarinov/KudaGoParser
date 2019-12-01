//
//  EventTableViewAdapter.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 25.11.2019.
//  Copyright © 2019 nikita. All rights reserved.
//

import UIKit

class EventTableViewAdapter: NSObject {
    
    var event: [Event] = []
    var cities: [Cities] = []
    var page = 1
    var locationSlug = "msk"
    var locationName = "Москва"
    
    weak var eventViewController: EventViewController?
    
    private var eventsService = EventsService()
    private let currentDate = Date().timeIntervalSince1970
    
    fileprivate (set) var tableView: UITableView
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }
    
    func configure(with result: [Event]) {
        self.event = result
        self.tableView.reloadData()
    }
    
    func configure(with cities: [ Cities]) {
        self.cities = cities
    }
    
}

extension EventTableViewAdapter: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return event.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EventTableViewCell
        
        cell.titleLabel.text = event[indexPath.row].title.uppercased()
        cell.descriptionLabel.text = event[indexPath.row].description
        let price = event[indexPath.row].price
        if  price == "" {
            cell.priceLabel.text = "Бесплатно"
        } else {
            cell.priceLabel.text = price
        }
        
        if let place = event[indexPath.row].place?.address {
            cell.placeLabel.text = place
            cell.placeStackView.isHidden = false
        } else {
            cell.placeStackView.isHidden = true
        }
        
        if let startUnixDate = event[indexPath.row].dates.first?.start, let endUnixDate = event[indexPath.row].dates.first?.end {
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
        }
        
        if  let imageURL = event[indexPath.row].images.first?.thumbnails.picture {
            let placeholder = UIImage(named: "not_found")
            cell.picture.loadImage(with: imageURL, placeholder: placeholder)
        }
        return cell
    }
}

extension EventTableViewAdapter: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = tableView.cellForRow(at: indexPath) as! EventTableViewCell
        
        let controller: DetailViewController = DetailViewController.loadFromStoryboard()

        let id = event[indexPath.row].id
        if let bodyText = event[indexPath.row].bodyText {
            controller.eventDetail = bodyText
        } else {
            controller.eventDetail = ""
        }
        let desc = event[indexPath.row].description
        let title = event[indexPath.row].title
        if let latitude = event[indexPath.row].place?.coords?.lat, let longitude = event[indexPath.row].place?.coords?.lon {
            controller.lat = latitude
            controller.lon = longitude
        } else {
            controller.lat = nil
            controller.lon = nil
        }
        controller.eventId = id
        controller.eventTitle = title
        controller.eventDesc = desc
        controller.eventPrice = cell.priceLabel.text
        controller.eventDate = cell.dateLabel.text
        if !cell.placeStackView.isHidden {
            controller.eventPlace = cell.placeLabel.text
        } else {
             controller.eventPlace = nil
        }
        
        eventViewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if indexPath.row == event.count - 1 {
            page += 1
            
            eventsService.getPagination(currentDate: currentDate, location: locationSlug, page: page) { result in
                switch result {
                case .data(let event ):
                    self.event.append(contentsOf: event)
                    self.tableView.reloadData()
                case .error:
                    print("error")
                }
            }
        }
    }
}
