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
    var listOfImages = [imageStruct]()
    
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
                    let title = eachElement.title
                    let description = eachElement.description
                    let price = eachElement.price
                    let place = eachElement.place
                    let address = place?.address
                    let images = eachElement.images
                    for eachImage in images {
                        let image = eachImage.image
                        self.listOfImages.append(imageStruct(image: image))
                    }
                    self.listOfFields.append(resultStruct(title: title, description: description,place: place, price: price, images: images))
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

