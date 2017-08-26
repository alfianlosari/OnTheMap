//
//  LoginStore.swift
//  OnTheMap
//
//  Created by Alfian Losari on 19/08/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import Foundation

typealias LoginResponse = (_ session: [String: Any]?, _ error: Error?) -> Void

struct LoginStore {
    
    static let loginURL = URL(string: "https://www.udacity.com/api/session")!
    
    static func getSession(username: String, password: String, completionHandler: @escaping LoginResponse) {
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let bodyObject: [String : Any] = [
            "udacity": [
                "username": username,
                "password": password
            ]
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async { completionHandler(nil, error) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 || httpResponse.statusCode <= 299 else {
                let error = NSError(domain: "Login", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Email or Password."])
                DispatchQueue.main.async { completionHandler(
                    nil, error) }
                return
            }
            
            
            let range = Range(5..<data!.count)
            let newData = data!.subdata(in: range)
            let session = try! JSONSerialization.jsonObject(with: newData, options: []) as? [String: Any]
            DispatchQueue.main.async { completionHandler(session, nil) }
        }
        
        task.resume()
    }
    
    
}
