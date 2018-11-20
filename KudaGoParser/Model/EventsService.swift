//
//  ParseManager.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 14.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

class EventsService {
    
    var listOfFields = [Result]()
    var listOfAddress = [Place]()
    var listOfImages = [Size]()
    var listOfDates = [Dates]()
    var listOfDetailImages = [Size]()
    var listOfCoords = [Coords]()
    var listOfCities = [Cities]()
    
    private var listOfStart = [Double]()
    private var listOfEnd = [Double]()
    
    func jsonTaskWith(request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration)
        var request = request
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard let HTTPResponse = response as? HTTPURLResponse else {
                let userInfo = [ NSLocalizedDescriptionKey: NSLocalizedString("Missing HTTP Response", comment: "") ]
                let error = NSError(domain: "", code: 0, userInfo: userInfo)
                completionHandler(nil, nil, error)
                return
            }
            if data == nil {
                if let error = error {
                    completionHandler(nil, HTTPResponse, error)
                }
            } else {
                completionHandler(data, HTTPResponse, nil)
            }
        }
        task.resume()
    }
    
    func getEvents(currentDate: Double, location: String, completion: @escaping() -> ()) {
        
        let request = ParseType.events(currentDate: currentDate, location: location).request
        
        jsonTaskWith(request: request) { (data, request, error) in
            
            guard let data = data else { return }
            do {
                let eventJSON = try JSONDecoder().decode(Events.self, from: data)
                self.parseEvents(array: eventJSON)
                
                DispatchQueue.main.async {
                    completion()
                }
            } catch let jsonErr as NSError {
                print ("error:", jsonErr)
            }
        }
    }
    
    func getImages(id: Int, completion: @escaping() -> ()) {
        
        let request = ParseType.detail(id: id).request
        
        jsonTaskWith(request: request) { (data, request, error) in
            guard let data = data else { return }
            do {
                let imagesJSON = try JSONDecoder().decode(DetailImages.self, from: data)
                self.parseImages(array: imagesJSON)
                
                DispatchQueue.main.async {
                    completion()
                }
            } catch let jsonErr as NSError {
                print ("error:", jsonErr)
            }
        }
    }
    
    func getCities() {
    
        let request = ParseType.cities.request
        
        jsonTaskWith(request: request) { (data, request, error) in
            guard let data = data else { return }
            do {
                let citiesJSON = try JSONDecoder().decode([Cities].self, from: data)
                self.parseCities(array: citiesJSON)
                
            } catch let jsonErr as NSError {
                print ("error:", jsonErr)
            }
        }
    }
    
    func getPullToRefresh(currentDate: Double, location: String, completion: @escaping() -> ()) {
        
        let request = ParseType.events(currentDate: currentDate, location: location).request
        
        jsonTaskWith(request: request) { (data, request, error) in
            guard let data = data else { return }
            do {
                
                self.clearData()
                let eventJSON = try JSONDecoder().decode(Events.self, from: data)
                self.parseEvents(array: eventJSON)
                
                DispatchQueue.main.async {
                    completion()
                }
            } catch let jsonErr as NSError {
                print ("error:", jsonErr)
            }
        }
    }
   
    func getPagination(currentDate: Double, location: String, page: Int, completion: @escaping() -> ()) {
        
        let request = ParseType.pages(page: page, currentDate: currentDate, location: location).request
        
        jsonTaskWith(request: request) { (data, request, error) in
            do {
                guard let data = data else { return }
                let eventJSON = try JSONDecoder().decode(Events.self, from: data)
                self.parseEvents(array: eventJSON)
                
                DispatchQueue.main.async {
                    completion()
                }
            } catch let jsonErr as NSError {
                print ("error:", jsonErr)
            }
        }
    }
    
    private func clearData() {
        listOfFields.removeAll()
        listOfDates.removeAll()
        listOfAddress.removeAll()
        listOfImages.removeAll()
        listOfCoords.removeAll()
        listOfDetailImages.removeAll()
    }
    
    private func parseEvents(array: Events ) {
        
        for eachElement in array.results {
            let id = eachElement.id
            let title = eachElement.title
            let description = eachElement.description
            let price = eachElement.price
            let place = eachElement.place
            let address = place?.address
            let coords = place?.coords
            let lat = coords?.lat
            let lon = coords?.lon
            let bodyText = eachElement.bodyText
            let images = eachElement.images
            for eachImage in images {
                let picture = eachImage.thumbnails.picture
                self.listOfImages.append(Size(picture: picture))
                break
            }
            let dates = eachElement.dates
            for eachDates in dates {
                let start = eachDates.start
                let end = eachDates.end
                self.listOfStart.append(start)
                self.listOfEnd.append(end)
            }
            self.listOfDates.append(Dates(start: self.listOfStart.first!, end: self.listOfEnd.last!))
            self.listOfStart.removeAll()
            self.listOfEnd.removeAll()
            self.listOfFields.append(Result(id: id,title: title, description: description,place: place, price: price, images: images, dates: dates,bodyText: bodyText)) 
            self.listOfAddress.append(Place(address: address, coords: coords))
            self.listOfCoords.append(Coords(lat: lat, lon: lon))
        }
        
    }
    
    private func parseImages(array: DetailImages) {
        
        for eachElement in array.images {
            let image = eachElement.thumbnails.picture
            self.listOfDetailImages.append(Size(picture: image))
        }
    }
    
    private func parseCities( array: [Cities]) {
        for eachElement in array {
            let name = eachElement.name
            let slug = eachElement.slug
            self.listOfCities.append(Cities(name: name, slug: slug))
        }
    }
    
}

