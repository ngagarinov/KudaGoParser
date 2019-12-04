//
//  NetworkService.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 24.11.2019.
//  Copyright © 2019 nikita. All rights reserved.
//

import Foundation

class NetworkService {
    
    func createRequest(with request: URLRequest, completionHandler: @escaping (Data?, Error?) -> Void) {
        
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration)
        var request = request
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if data == nil {
                if let error = error {
                    print("error: \(error)")
                    completionHandler(nil, error)
                }
            } else {
                completionHandler(data, nil)
            }
        }
        task.resume()
    }
}
