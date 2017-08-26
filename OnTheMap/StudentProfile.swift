//
//  StudentProfile.swift
//  OnTheMap
//
//  Created by Alfian Losari on 23/08/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import Foundation

struct StudentProfile {
    
    var id: String
    var firstName: String
    var lastName: String
    

    
}

extension StudentProfile {
    
    init?(dictionary: [String: Any]) {
        guard
            let user = dictionary["user"] as? [String: Any],
            let key = user["key"] as? String,
            let firstName = user["first_name"] as? String,
            let lastName = user["last_name"] as? String
            else {
                return nil
        }
        self.init(id: key, firstName: firstName, lastName: lastName)
    }
    
}
