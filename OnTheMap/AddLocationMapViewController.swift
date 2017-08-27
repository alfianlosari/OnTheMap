//
//  AddLocationMapViewController.swift
//  OnTheMap
//
//  Created by Alfian Losari on 23/08/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import UIKit
import MapKit

class AddLocationMapViewController: UIViewController {

    var appDelegate: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    var coordinate: CLLocationCoordinate2D!
    var mapString: String!
    var mediaURL: String!
    var currentObjectId: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = mapString
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500)
        let adjustedRegion = mapView.regionThatFits(region)
        mapView.setRegion(adjustedRegion, animated: true)
    }
    

    @IBAction func post(_ sender: Any) {
        guard let accountId = appDelegate.appData?.accountId else {
            self.showAlert(title: nil, message: "Unable to retrieve login session")
            return
        }
        
        showActivityIndicator(isShowing: true)
        ProfileStore.getProfile(accountId: accountId) {[weak self] (profile, error) in
            guard let strongSelf = self else { return }
            
            if let error = error {
                strongSelf.showActivityIndicator(isShowing: false)
                strongSelf.showAlert(title: nil, message: error.localizedDescription)
                return
            }
            
            guard let profile = profile else { return }
            
            let studentInformation = StudentInformation(firstName: profile.firstName, lastName: profile.lastName, latitude: strongSelf.coordinate.latitude, longitude: strongSelf.coordinate.longitude, mapString: strongSelf.mapString, mediaURL: strongSelf.mediaURL, objectId: strongSelf.currentObjectId, uniqueKey: profile.id, createdAt: nil, updatedAt: nil)
            
            if studentInformation.objectId == nil {
                LocationStore.post(studentLocation: studentInformation, completionHandler: { [weak self](response, error) in
                    guard let strongSelf = self else { return }
                    strongSelf.showActivityIndicator(isShowing: false)
                    if let error = error {
                        strongSelf.showAlert(title: nil, message: error.localizedDescription)
                        return
                    }
                    
                    guard let rootViewController = strongSelf.navigationController?.viewControllers.first as? RefreshViewControllerType else { return }
                    rootViewController.refresh(strongSelf)
                    
                    strongSelf.navigationController?.popToRootViewController(animated: true)
                    
                })
            } else {
                LocationStore.put(studentLocation: studentInformation, completionHandler: { [weak self] (updatedAt, error) in
                    guard let strongSelf = self else { return }
                    strongSelf.showActivityIndicator(isShowing: false)
                    if let error = error {
                        strongSelf.showAlert(title: nil, message: error.localizedDescription)
                        return
                    }
                    
                    guard let rootViewController = strongSelf.navigationController?.viewControllers.first as? RefreshViewControllerType else { return }
                    rootViewController.refresh(strongSelf)
                    
                    strongSelf.navigationController?.popToRootViewController(animated: true)
                })
            }
        }

    }
    
    
    
    
    
    func showActivityIndicator(isShowing showing: Bool) {
        showing ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
        overlayView.isHidden = showing ? false : true
        view.isUserInteractionEnabled = !showing
        
    }
}
