//
//  DecodableStructures.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 14.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

// структуры для парсинга списка
struct EventsStruct: Decodable {
    let results: [ResultStruct]
}

struct ResultStruct: Decodable {
    let id: Int
    let title: String
    let description: String
    let place: PlaceStruct?
    let price: String
    let images: [ImageStruct]
    let dates: [DatesStruct]
    let bodyText: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, place, price, images, dates
        case bodyText = "body_text"
    }
}

struct DatesStruct: Decodable {
    let start: Double
    let end: Double
}

struct ImageStruct: Decodable {
    let thumbnails: SizeStruct
}

struct SizeStruct: Decodable {
    let picture: String
    
    enum CodingKeys: String, CodingKey {
        case picture = "640x384"
    }
}

struct PlaceStruct: Decodable {
    let address: String?
    let coords: CoordsStruct?
}

struct CoordsStruct: Decodable {
    let lat: Double?
    let lon: Double?
}

struct DetailImagesStruct: Decodable {
    let images: [ImageStruct]
}

struct CitiesStruct: Decodable {
    let name: String
    let slug: String
}

