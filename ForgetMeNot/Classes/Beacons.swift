//
//  Beacons.swift
//  ForgetMeNot
//
//  Created by Seth on 7/27/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import UIKit

enum Beacons {
    // proximity
    case lightBlue
    case green
    case purple
    
    var uuid: String {
        switch self {
        case .lightBlue:    return "B9407F30-F5F8-466E-AFF9-25556B57FE6D"
        case .green:        return "B9407F30-F5F8-466E-AFF9-25556B57FE6D"
        case .purple:       return "B9407F30-F5F8-466E-AFF9-25556B57FE6D"
        }
    }
    
    var major: Int {
        switch self {
        case .lightBlue:    return 25510
        case .green:        return 16685
        case .purple:       return 36494
        }
    }
    
    var minor: Int {
        switch self {
        case .lightBlue:    return 32154
        case .green:        return 12762
        case .purple:       return 57746
        }
    }
    
    var name: String {
        switch self {
        case .lightBlue:    return "Arkham"
        case .green:        return "Batcave"
        case .purple:       return "Quinjet"
        }
    }
    
    var coordinate: CGPoint {
        switch self {
        case .lightBlue:
            return CGPoint(x: 0, y: 0)
        case .green:
            return CGPoint(x: 3, y: 0)
        case .purple:
            return CGPoint(x: 1.5, y: 4)
        }
    }
    
    var item: Item {
        return Item.init(name: name, icon: 0, uuid: UUID(uuidString: uuid)!, majorValue: major, minorValue: minor, coordinates: coordinate)
    }
}
