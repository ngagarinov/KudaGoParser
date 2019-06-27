//
//  ParseManager.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 14.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

class EventsService {
    
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
    
    func getEvents(currentDate: Double, location: String, completion: @escaping([Result]?) -> ()) {
        
        let request = ParseType.events(currentDate: currentDate, location: location).request
        
        jsonTaskWith(request: request) { (data, request, error) in
            
            guard let data = data else { return }
            do {
                let eventJSON = try JSONDecoder().decode(Events.self, from: data)
                
                DispatchQueue.main.async {
                    completion(eventJSON.results)
                }
            } catch let jsonErr as NSError {
                print ("error:", jsonErr)
            }
        }
    }
    
    func getImages(id: Int, completion: @escaping([Image]?) -> ()) {
        
        let request = ParseType.detail(id: id).request
        
        jsonTaskWith(request: request) { (data, request, error) in
            guard let data = data else { return }
            do {
                let imagesJSON = try JSONDecoder().decode(DetailImages.self, from: data)
                
                DispatchQueue.main.async {
                    completion(imagesJSON.images)
                }
            } catch let jsonErr as NSError {
                print ("error:", jsonErr)
            }
        }
    }
    
    func getCities(completion: @escaping([Cities]?) -> ()) {
    
        let request = ParseType.cities.request
        
        jsonTaskWith(request: request) { (data, request, error) in
            guard let data = data else { return }
            do {
                let citiesJSON = try JSONDecoder().decode([Cities].self, from: data)
                completion(citiesJSON)
                
            } catch let jsonErr as NSError {
                print ("error:", jsonErr)
            }
        }
    }
    
    func getPullToRefresh(currentDate: Double, location: String, completion: @escaping([Result]?) -> ()) {
        
        let request = ParseType.events(currentDate: currentDate, location: location).request
        
        jsonTaskWith(request: request) { (data, request, error) in
            guard let data = data else { return }
            do {
                let eventJSON = try JSONDecoder().decode(Events.self, from: data)
                
                DispatchQueue.main.async {
                    completion(eventJSON.results)
                }
            } catch let jsonErr as NSError {
                print ("error:", jsonErr)
            }
        }
    }
   
    func getPagination(currentDate: Double, location: String, page: Int, completion: @escaping([Result]?) -> ()) {
        
        let request = ParseType.pages(page: page, currentDate: currentDate, location: location).request
        
        jsonTaskWith(request: request) { (data, request, error) in
            do {
                guard let data = data else { return }
                let eventJSON = try JSONDecoder().decode(Events.self, from: data)
                
                DispatchQueue.main.async {
                    completion(eventJSON.results)
                }
            } catch let jsonErr as NSError {
                print ("error:", jsonErr)
            }
        }
    }
    
}
