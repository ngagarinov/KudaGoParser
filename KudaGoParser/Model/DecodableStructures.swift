//
//  DecodableStructures.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 14.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

struct eventsStruct: Decodable {
    
    let results: [resultStruct]
    
}

struct resultStruct: Decodable {
    
    let id: Int
    let title: String
    let description: String
    let place: placeStruct?
    let price: String
    let images: [imageStruct]
    let dates: [datesStruct]
    let bodyText: String
    
    enum keys: String,CodingKey {
        case bodyText = "body_text"
    }
    
}

struct datesStruct: Decodable {
    
    let start: Double
    let end: Double
}

struct imageStruct: Decodable {
    
    let thumbnails: sizeStruct
}

struct sizeStruct: Decodable {
    
    let picture: String
    
    enum CodingKeys: String, CodingKey {
        case picture = "640x384"
    }
    
}
struct placeStruct: Decodable {
    
    let address: String?
}
