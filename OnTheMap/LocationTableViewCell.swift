//
//  LocationTableViewCell.swift
//  OnTheMap
//
//  Created by Alfian Losari on 19/08/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    
    func setup(location: StudentInformation) {
        locationLabel.text = location.fullName
        websiteLabel.text = location.mediaURL
    }

}
