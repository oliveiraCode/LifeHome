//
//  User.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-06-14.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit

class User {
    var id:String!
    var username:String!
    var email:String!
    var password:String!
    var phone:String!
    var image:UIImage!
    
    func resetValues() {
        self.id = nil
        self.email = nil
        self.image = nil
        self.password = nil
        self.phone = nil
        self.username = nil
    }
}
