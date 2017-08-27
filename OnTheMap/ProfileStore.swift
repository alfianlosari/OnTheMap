//
//  ProfileStore.swift
//  OnTheMap
//
//  Created by Alfian Losari on 23/08/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import Foundation

typealias ProfileResponse = (_ profile: StudentProfile?, _ error: Error?) -> Void

struct ProfileStore {
    
    static let profileURL = URL(string: "https://www.udacity.com/api/users")!

    static func getProfile(accountId: String, completionHandler: @escaping ProfileResponse) {
        var request = URLRequest(url: profileURL.appendingPathComponent(accountId))
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async { completionHandler(nil, error) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299  else {
                let error = NSError(domain: "Login", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Email or Password."])
                DispatchQueue.main.async { completionHandler(nil, error) }
                return
            }
            
            
            let range = Range(5..<data!.count)
            let newData = data!.subdata(in: range)
            let profileDict = try! JSONSerialization.jsonObject(with: newData, options: []) as! [String: Any]
            let profile = StudentProfile(dictionary: profileDict)
            DispatchQueue.main.async { completionHandler(profile, nil) }
        }
        
        task.resume()
    }
    
    
}
