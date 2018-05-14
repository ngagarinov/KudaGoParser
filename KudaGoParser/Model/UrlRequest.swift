//
//  UrlPoint.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 14.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

protocol FinalURLPoint {
    var baseURL: URL { get }
    var path: String { get }
    var request: URLRequest { get }
}

enum parseType: FinalURLPoint {
    
    case events
    case pages(page: Int)
    
    var baseURL: URL {
        return URL(string: "https://kudago.com/public-api/v1.4/")!
    }
    var path: String {
        switch self {
        case .events:
            return "events/?location=msk&fields=title,place,description,price,images,dates&expand=place,dates"
        case .pages(let page):
            return "events/?location=msk&fields=title,place,description,price,images,dates&page=\(page)"
            
        }
    }
    var request: URLRequest {
        let url = URL(string: path, relativeTo: baseURL)
        return URLRequest(url: url!)
    }
    
}
