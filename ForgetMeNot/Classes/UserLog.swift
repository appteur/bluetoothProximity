//
//  UserLog.swift
//  ForgetMeNot
//
//  Created by Yuxi Lin on 7/27/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import Foundation

class UserLog {
    var timeStamp: TimeInterval
    var locationName: String
    init(locationName: String, timeStamp: TimeInterval) {
        self.locationName = locationName
        self.timeStamp = timeStamp
    }
}
