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
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        ref = Database.database().reference()
    }

    func getUsers(completion: @escaping ([User]) -> Void) {
        ref.child("logs").observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            // Get user value
            guard let usersDict = snapshot.value as? [String : [String : Any]], let list = self?.parseUsers(userList: usersDict) else {
                print("Received unexpected value from get users update: \(String(describing: snapshot.value))")
                return
            }
            
            completion(list)
            
        }) { (error) in
            print(error.localizedDescription)
            completion([])
        }
    }
    
    func sendEvent(name:String, user: User) {
        self.ref.child("logs").child(name).setValue([name: ["timestamp" : user.log.timeStamp, "locationName" : user.log.locationName]])
    }
    
    func parseUsers(userList: [String : [String : Any]]) -> [User] {
        
        var users: [User] = []
        
        for (key,value) in userList {
            let timestamp = value["timestamp"] as? TimeInterval ?? 0.0
            let location = value["locationName"] as? String ?? ""

            
            let log = UserLog.init(locationName: location, timeStamp: timestamp)
            let user = User.init(name: key, log: log)
            
            users.append(user)
        }
        return users
    }
}
