//
//  FirebaseManager.swift
//  ForgetMeNot
//
//  Created by Yuxi Lin on 7/27/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import UIKit
import Firebase

class FirebaseManager: NSObject {

    var ref: DatabaseReference!
    
    override init() {
        super.init()
        
        ref = Database.database().reference()
    }

}
