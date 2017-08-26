//
//  Helper.swift
//  OnTheMap
//
//  Created by Alfian Losari on 19/08/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import UIKit
import MapKit

let didStartRefreshLocationsNotification = Notification.Name(rawValue: "didStartRefreshLocationNotification")
let didFinishRefreshLocationsNotification = Notification.Name(rawValue: "didFinishRefreshLocationNotification")

func getKeyboardHeight(_ notification: Notification) -> CGFloat {
    let userInfo = notification.userInfo
    let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
    return keyboardSize.cgRectValue.height
}


extension MKPointAnnotation {
    
    static func annotation(from studentInformation: StudentInformation) -> MKPointAnnotation {
        let coordinate = CLLocationCoordinate2D(latitude: studentInformation.latitude, longitude: studentInformation.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(studentInformation.firstName) \(studentInformation.lastName)"
        annotation.subtitle = studentInformation.mediaURL
        return annotation
    }
    
    
}

