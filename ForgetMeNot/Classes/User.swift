//
//  User.swift
//  ForgetMeNot
//
//  Created by Yuxi Lin on 7/27/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import Foundation

class User {
    var name: String
    var log: UserLog
    init(name: String, log: UserLog) {
        self.name = name
        self.log = log
    }
}
