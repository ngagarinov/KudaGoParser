//
//  Size.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 02.07.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import Foundation

struct Size: Decodable {
    let picture: String
    
    enum CodingKeys: String, CodingKey {
        case picture = "640x384"
    }
}
