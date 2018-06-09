//
//  Connectivity.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 01.06.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import Alamofire

class Connectivity {
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
