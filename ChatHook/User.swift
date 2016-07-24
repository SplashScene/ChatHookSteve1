//
//  User.swift
//  ChatHook
//
//  Created by Kevin Farm on 7/24/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import Foundation
import CoreLocation


class User{
    let location: CLLocation?
    let userName: String
    let imageName: String
    
    init(latitude: Double, longitude: Double, userName: String, imageName: String){
        location = CLLocation(latitude: latitude, longitude: longitude)
        self.userName = userName
        self.imageName = imageName
    }
    
}
