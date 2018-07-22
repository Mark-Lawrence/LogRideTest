//
//  ParksModel.swift
//  LogRide Test
//
//  Created by Mark Lawrence on 7/21/18.
//  Copyright © 2018 Mark Lawrence. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase


struct ParksList {
    
    let ref: DatabaseReference?
    let key: String
    
    let parkID: Int
    let favorite: Bool
    let ridesRidden: Int
    let totalRides: Int
    let incrementorEnabled: Bool

    
    init(parkID: Int, favorite: Bool, ridesRidden: Int, totalRides: Int, incrementorEnabled: Bool, key: String = "") {
        self.ref = nil
        self.key = key
        self.parkID = parkID
        self.favorite = favorite
        self.ridesRidden = ridesRidden
        self.totalRides = totalRides
        self.incrementorEnabled = incrementorEnabled
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let parkID = value["parkID"] as? Int,
            let ridesRidden = value["ridesRidden"] as? Int,
            let totalRides = value["totalRides"] as? Int,
            let incrementorEnabled = value["incrementorEnabled"] as? Bool,
            let favorite = value["favorite"] as? Bool else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.parkID = parkID
        self.favorite = favorite
        self.ridesRidden = ridesRidden
        self.totalRides = totalRides
        self.incrementorEnabled = incrementorEnabled
    }
    
    func toAnyObject() -> Any {
        return [
            "parkID": parkID,
            "favorite": favorite,
            "ridesRidden": ridesRidden,
            "totalRides": totalRides,
            "incrementorEnabled": incrementorEnabled
        ]
    }
}

