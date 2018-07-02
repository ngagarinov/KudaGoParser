//
//  Place.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 02.07.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import Foundation

struct Place: Decodable {
    let address: String?
    let coords: Coords?
}
