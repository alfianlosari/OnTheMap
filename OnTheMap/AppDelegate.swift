//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by Alfian Losari on 19/08/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locations: [StudentInformation] = []
    var loginSession: [String: Any]?
    var accountId: String? {
        guard let loginSession = self.loginSession,
            let account = loginSession["account"] as? [String: Any],
            let accountId = account["key"] as? String
            else {
                return nil
        }
        return accountId
    }
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().tintColor = UIColor(red: 3/255, green: 179/255, blue: 228/255, alpha: 1.0)
        
        return true
    }

}

