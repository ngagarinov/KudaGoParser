//
//  ParseManager.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 14.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

class ParseManager {
    
    var listOfFields = [resultStruct]()
    var listOfAddress = [placeStruct]()
    var listOfImages = [sizeStruct]()
    var listOfDates = [datesStruct]()
    var listOfStart = [Double]()
    var listOfEnd = [Double]()
    
    func parseKudaGo (request: URLRequest, completion: @escaping(Any) -> ()) {
        
        let sessionConf = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConf)
        
        var request = request
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else {return}
            guard error == nil else {return}
            do {
                let genreAr = try JSONDecoder().decode(eventsStruct.self, from: data)
                // print( genreAr)
                for eachElement in genreAr.results {
                    let id = eachElement.id
                    let title = eachElement.title
                    let description = eachElement.description
                    let price = eachElement.price
                    let place = eachElement.place
                    let address = place?.address
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
                    self.listOfFields.append(resultStruct(id: id,title: title, description: description,place: place, price: price, images: images,dates: dates,bodyText: bodyText))
                    self.listOfAddress.append(placeStruct(address: address))
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
}

