//
//  AppData.swift
//  OnTheMap
//
//  Created by Alfian Losari on 27/08/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import Foundation

struct AppData {
    
    var locations: [StudentInformation]
    let loginSession: [String: Any]
    var accountId: String? {
        guard
            let account = loginSession["account"] as? [String: Any],
            let accountId = account["key"] as? String
            else {
                return nil
        }
        return accountId
    }
    
}
