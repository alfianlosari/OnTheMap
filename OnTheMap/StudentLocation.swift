//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Alfian Losari on 19/08/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import Foundation

struct StudentInformation {
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mapString: String
    let mediaURL: String
    let objectId: String?
    let uniqueKey: String
    let createdAt: String?
    let updatedAt: String?
    
    var fullName: String { return "\(firstName) \(lastName)" }
}

extension StudentInformation {
    
    init?(dictionary: [String: Any]) {
        guard
            let firstName = dictionary["firstName"] as? String,
            let lastName = dictionary["lastName"] as? String,
            let latitude = dictionary["latitude"] as? Double,
            let longitude = dictionary["longitude"] as? Double,
            let mapString = dictionary["mapString"] as? String,
            let mediaURL = dictionary["mediaURL"] as? String,
            let objectId = dictionary["objectId"] as? String,
            let uniqueKey = dictionary["uniqueKey"] as? String,
            let createdAt = dictionary["createdAt"] as? String,
            let updatedAt = dictionary["updatedAt"] as? String
            else {
                return nil
        }
        self.init(firstName: firstName, lastName: lastName, latitude: latitude, longitude: longitude, mapString: mapString, mediaURL: mediaURL, objectId: objectId, uniqueKey: uniqueKey, createdAt: createdAt, updatedAt: updatedAt)
    }
    
}

