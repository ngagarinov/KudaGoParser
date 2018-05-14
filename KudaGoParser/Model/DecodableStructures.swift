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
    
    let title: String
    let description: String
    let place: placeStruct?
    let price: String
    let images: [imageStruct]
    
}
struct imageStruct: Decodable {
    let image: String
}

struct placeStruct: Decodable {
    
    let address: String?
}
