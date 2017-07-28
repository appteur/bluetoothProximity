//
//  LocationEvent.swift
//  ForgetMeNot
//
//  Created by Seth on 7/27/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import Foundation

class LocationEvent {
    
    var isValid = false
    
    var user: String?
    var timestamp: TimeInterval = Date().timeIntervalSince1970
    var location: String?
    
    init(item: Item) {
        
        // set user if we have one
        guard let user = UserDefaults.standard.value(forKey: "com.bt.name") as? String else {
            return
        }
        
        self.user = user
        
        // load location from item
        guard item.locationString().contains("Unknown") == false else {
            return
        }
        
        location = item.name
        isValid = true
    }
}
