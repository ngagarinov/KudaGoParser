//
//  AnnotationPin.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 28.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import MapKit

final class AnnotationPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
