//
//  AdAnnotation.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-06-08.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AdAnnotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String,subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
