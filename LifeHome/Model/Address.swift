//
//  Address.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-06-05.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit
import CoreLocation

class Address {
    var street:String?
    var city:String?
    var province:String?
    var postalCode:String?
    var latitude:Double?
    var longitude:Double?
    var distance:Double?
    
    func addressGeoCode () -> String{
        return "\(self.street!), \(self.city!), \(self.province!) \(self.postalCode!)"
    }

    
}
