//
//  LocationStore.swift
//  OnTheMap
//
//  Created by Alfian Losari on 19/08/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import Foundation

typealias StudentLocationPostResponse = (createdAt: String, objectId: String)
typealias GetLocationsResponse = (_ locations: [StudentInformation]?, _ error: Error?) -> Void
typealias PostStudentLocationResponse = (_ response: StudentLocationPostResponse?, _ error: Error?) -> Void
typealias PutStudentLocationResponse = (_ updatedAt: String?, _ error: Error?) -> Void

struct LocationStore {
    
    static let getLocationsURL = URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!
    static let postLocationURL = URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!
    static let putLocationURL = URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!
    
    
    static func getStudentLocations(completionHandler: @escaping GetLocationsResponse) {
        var request = URLRequest(url: getLocationsURL)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
   
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async { completionHandler(nil, error)  }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                guard let results = json["results"] as? [[String: Any]] else {
                    completionHandler([], nil)
                    return
                }
                
                let locations = results.map { StudentInformation(dictionary: $0) }.flatMap { $0 }
                DispatchQueue.main.async { completionHandler(locations, nil) }
            } catch {
                DispatchQueue.main.async { completionHandler(nil, error) }
            }
        }
        
        task.resume()
    }
    
    static func post(studentLocation: StudentInformation, completionHandler: @escaping PostStudentLocationResponse) {
        var request = URLRequest(url: postLocationURL)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let bodyObject: [String: Any] = [
            "uniqueKey": studentLocation.uniqueKey,
            "firstName": studentLocation.firstName,
            "lastName": studentLocation.lastName,
            "mapString": studentLocation.mapString,
            "mediaURL": studentLocation.mediaURL,
            "latitude": studentLocation.latitude,
            "longitude": studentLocation.longitude
        ]
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async { completionHandler(nil, error) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 || httpResponse.statusCode <= 299  else {
                let error = NSError(domain: "Post Location", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to post location"])
                DispatchQueue.main.async { completionHandler(
                    nil, error) }
                return
            }
            
            let dict = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            let createdAt = dict["createdAt"] as! String
            let objectId = dict["objectId"] as! String
            DispatchQueue.main.async {
                completionHandler((createdAt, objectId), nil)
            }
        }
        
        task.resume()
    }
    
    static func put(studentLocation: StudentInformation, completionHandler: @escaping PutStudentLocationResponse) {
        guard let objectId = studentLocation.objectId else {
            let error = NSError(domain: "Put Location", code: 0, userInfo: [NSLocalizedDescriptionKey: "Object Id is not provided."])
            completionHandler(nil, error)
            return
        }
        
        var request = URLRequest(url: putLocationURL.appendingPathComponent(objectId))
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let bodyObject: [String: Any] = [
            "uniqueKey": studentLocation.uniqueKey,
            "firstName": studentLocation.firstName,
            "lastName": studentLocation.lastName,
            "mapString": studentLocation.mapString,
            "mediaURL": studentLocation.mediaURL,
            "latitude": studentLocation.latitude,
            "longitude": studentLocation.longitude
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async { completionHandler(nil, error) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 || httpResponse.statusCode <= 299  else {
                let error = NSError(domain: "PUT Location", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to put location"])
                DispatchQueue.main.async { completionHandler(
                    nil, error) }
                return
            }
            
            let dict = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            let updatedAt = dict["updatedAt"] as! String
            
            DispatchQueue.main.async {
                completionHandler(updatedAt, nil)
            }
        }
        
        task.resume()
    }
    
    
    
    
    
    
}
