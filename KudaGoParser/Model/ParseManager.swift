//
//  ParseManager.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 14.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

enum parser {
    case event
    case images
}

class ParseManager {
    
    var listOfFields = [resultStruct]()
    var listOfAddress = [placeStruct]()
    var listOfImages = [sizeStruct]()
    var listOfDates = [datesStruct]()
    var listOfStart = [Double]()
    var listOfEnd = [Double]()
    var listOfDetailImages = [sizeStruct]()
    var listOfCoords = [coordsStruct]()
    
    func parseKudaGo (request: URLRequest, parse: parser, completion: @escaping(Any) -> ()) {
        
        let sessionConf = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConf)
        
        var request = request
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else {return}
            guard error == nil else {return}
            do {
                switch parse {
                case .event:
                    let eventAr = try JSONDecoder().decode(eventsStruct.self, from: data)
                    
                    self.parseEvents(array: eventAr)
                case .images:
                    let imagesAr = try JSONDecoder().decode(detailImagesStruct.self, from: data)
                    self.parseImages(array: imagesAr)
                    
                }
                
                DispatchQueue.main.async {
                    completion(data)
                }
                
            } catch let jsonErr {
                print ("error:", jsonErr)
            }
        }
        
        task.resume()
    }
    
    func parseEvents(array: eventsStruct ) {
        
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
                self.listOfImages.append(sizeStruct(picture: picture))
                break
            }
            let dates = eachElement.dates
            for eachDates in dates {
                let start = eachDates.start
                self.listOfStart.append(start)
                let end = eachDates.end
                self.listOfEnd.append(end)
            }
            self.listOfDates.append(datesStruct(start: self.listOfStart.first!, end: self.listOfEnd.last!))
            self.listOfStart.removeAll()
            self.listOfEnd.removeAll()
            self.listOfFields.append(resultStruct(id: id,title: title, description: description,place: place, price: price, images: images, dates: dates,bodyText: bodyText))
            self.listOfAddress.append(placeStruct(address: address, coords: coords))
            self.listOfCoords.append(coordsStruct(lat: lat, lon: lon))
        }
        
    }
    
    func parseImages(array: detailImagesStruct) {
        
        for eachElement in array.images {
            let image = eachElement.thumbnails.picture
            self.listOfDetailImages.append(sizeStruct(picture: image))
        }
    }
    
}

