//
//  ParseManager.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 14.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

class ParseManager {
    
    var listOfFields = [ResultStruct]()
    var listOfAddress = [PlaceStruct]()
    var listOfImages = [SizeStruct]()
    var listOfDates = [DatesStruct]()
    var listOfDetailImages = [SizeStruct]()
    var listOfCoords = [CoordsStruct]()
    var listOfCities = [CitiesStruct]()
    private var listOfStart = [Double]()
    private var listOfEnd = [Double]()
    
    func JSONTaskWith(request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        let sessionConf = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConf)
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
        
        let request = parseType.events(currentDate: currentDate, location: location).request
        
        JSONTaskWith(request: request) { (data, request, error) in
            
            guard let data = data else { return }
            do {
                let eventJSON = try JSONDecoder().decode(EventsStruct.self, from: data)
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
        
        let request = parseType.detail(id: id).request
        
        JSONTaskWith(request: request) { (data, request, error) in
            guard let data = data else { return }
            do {
                let imagesJSON = try JSONDecoder().decode(DetailImagesStruct.self, from: data)
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
    
        let request = parseType.cities.request
        
        JSONTaskWith(request: request) { (data, request, error) in
            guard let data = data else { return }
            do {
                let citiesJSON = try JSONDecoder().decode([CitiesStruct].self, from: data)
                self.parseCities(array: citiesJSON)
                
            } catch let jsonErr as NSError {
                print ("error:", jsonErr)
            }
        }
    }
    
    func getPullToRefresh(currentDate: Double, location: String, completion: @escaping() -> ()) {
        
        let request = parseType.events(currentDate: currentDate, location: location).request
        
        JSONTaskWith(request: request) { (data, request, error) in
            guard let data = data else { return }
            do {
                
                self.clearData()
                let eventJSON = try JSONDecoder().decode(EventsStruct.self, from: data)
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
        
        let request = parseType.pages(page: page, currentDate: currentDate, location: location).request
        
        JSONTaskWith(request: request) { (data, request, error) in
            do {
                guard let data = data else { return }
                let eventJSON = try JSONDecoder().decode(EventsStruct.self, from: data)
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
    
    private func parseEvents(array: EventsStruct ) {
        
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
                self.listOfImages.append(SizeStruct(picture: picture))
                break
            }
            let dates = eachElement.dates
            for eachDates in dates {
                let start = eachDates.start
                self.listOfStart.append(start)
                let end = eachDates.end
                self.listOfEnd.append(end)
            }
            self.listOfDates.append(DatesStruct(start: self.listOfStart.first!, end: self.listOfEnd.last!))
            self.listOfStart.removeAll()
            self.listOfEnd.removeAll()
            self.listOfFields.append(ResultStruct(id: id,title: title, description: description,place: place, price: price, images: images, dates: dates,bodyText: bodyText))
            self.listOfAddress.append(PlaceStruct(address: address, coords: coords))
            self.listOfCoords.append(CoordsStruct(lat: lat, lon: lon))
        }
        
    }
    
    private func parseImages(array: DetailImagesStruct) {
        
        for eachElement in array.images {
            let image = eachElement.thumbnails.picture
            self.listOfDetailImages.append(SizeStruct(picture: image))
        }
    }
    
    private func parseCities( array: [CitiesStruct]) {
        for eachElement in array {
            let name = eachElement.name
            let slug = eachElement.slug
            self.listOfCities.append(CitiesStruct(name: name, slug: slug))
        }
    }
    
}

