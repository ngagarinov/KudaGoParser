//
//  ParseManager.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 14.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

class EventsService {
    
    enum Result<ResultDataType> {
           case data(ResultDataType)
           case error
       }
    
    var networkService: NetworkService
    
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }
    
    func getEvents(currentDate: Double, location: String, completion: @escaping(Result<[Event]>) -> ()) {
        
        let request = ParseType.events(currentDate: currentDate, location: location).request
        
        networkService.createRequest(with: request) { (data, error) in
            DispatchQueue.main.async {
                guard let data = data, let response = self.decodeJSON(type: Events.self, from: data) else {
                    completion(.error)
                    return
                }
                completion(.data(response.results))
            }
        }
    }
    
    func getImages(id: Int, completion: @escaping(Result<[Image]>) -> ()) {
        
        let request = ParseType.detail(id: id).request
        
        networkService.createRequest(with: request) { (data, error) in
            DispatchQueue.main.async {
                guard let data = data, let response = self.decodeJSON(type: DetailImages.self, from: data) else {
                    completion(.error)
                    return
                }
                completion(.data(response.images))
            }
        }
    }
    
    func getCities(completion: @escaping(Result<[Cities]>) -> ()) {
        
        let request = ParseType.cities.request
        networkService.createRequest(with: request) { (data, error) in
            DispatchQueue.main.async {
                guard let data = data, let response = self.decodeJSON(type: [Cities].self, from: data) else {
                    completion(.error)
                    return
                }
                completion(.data(response))
            }
        }
    }
    
    func getPullToRefresh(currentDate: Double, location: String, completion: @escaping(Result<[Event]>) -> ()) {
        
        let request = ParseType.events(currentDate: currentDate, location: location).request
        networkService.createRequest(with: request) { (data, error) in
            DispatchQueue.main.async {
                guard let data = data, let response = self.decodeJSON(type: Events.self, from: data) else {
                    completion(.error)
                    return
                }
                completion(.data(response.results))
            } 
        }
    }
    
    func getPagination(currentDate: Double, location: String, page: Int, completion: @escaping(Result<[Event]>) -> ()) {
        
        let request = ParseType.pages(page: page, currentDate: currentDate, location: location).request
        
        networkService.createRequest(with: request) { (data, error) in
            DispatchQueue.main.async {
                guard let data = data, let response = self.decodeJSON(type: Events.self, from: data) else {
                    completion(.error)
                    return
                }
                completion(.data(response.results))
            }
        }
    }
    
    func decodeJSON<T: Decodable>(type: T.Type, from: Data?) -> T? {
        let decoder = JSONDecoder()
        guard let data = from else {
            return nil
        }
        do {
            let objects = try decoder.decode(type.self, from: data)
            return objects
        } catch let jsonError {
            print("Failed to decode JSON", jsonError)
            return nil
        }
    }
}
