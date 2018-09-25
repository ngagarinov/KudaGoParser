//
//  UrlPoint.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 14.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

protocol URLPoint {
    var baseURL: URL { get }
    var path: String { get }
    var request: URLRequest { get }
}

enum ParseType: URLPoint {
    
    case events(currentDate: Double, location: String)
    case pages(page: Int, currentDate: Double, location: String)
    case detail(id: Int)
    case cities
    
    var baseURL: URL {
        return URL(string: "https://kudago.com/public-api/v1.4/")!
    }
    
    var path: String {
        switch self {
        case .events(let currentDate, let location):
            return "events/?location=\(location)&fields=id,title,place,description,price,images,dates,body_text&expand=images,place&actual_since=\(currentDate)&text_format=text&order_by=-publication_date"
        case .pages(let page, let currentDate, let location):
            return "events/?location=\(location)&fields=id,title,place,description,price,images,dates,body_text&expand=images,place&page=\(page)&actual_since=\(currentDate)&text_format=text&order_by=-publication_date"
        case .detail(let id):
            return "events/\(id)/?fields=images&expand=images"
        case .cities:
            return "locations/?lang=ru"
        }
    }
    
    var request: URLRequest {
        let url = URL(string: path, relativeTo: baseURL)
        return URLRequest(url: url!)
    }
}
