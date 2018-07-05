//
//  Result.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 02.07.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import Foundation

struct Result: Decodable {
    let id: Int
    let title: String
    let description: String
    let place: Place?
    let price: String
    let images: [Image]
    let dates: [Dates]
    let bodyText: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, place, price, images, dates
        case bodyText = "body_text"
    }
    
    init(id: Int, title: String, description: String, place: Place?, price: String, images: [Image], dates: [Dates], bodyText: String?) {
        self.id = id
        self.title = title
        self.description = description
        self.place = place
        self.price = price
        self.images = images
        self.dates = dates
        self.bodyText = bodyText
    }
}
