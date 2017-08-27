//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Alfian Losari on 19/08/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import UIKit
import MapKit

private let postLocationSegueIdentifier = "PostLocation"

class MapViewController: UIViewController, RefreshViewControllerType {
    
    var appDelegate: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }
    var locations: [StudentInformation] { return appDelegate.appData?.locations ?? [] }
    var isRefreshingData = false
    var locationTableViewController: LocationTableViewController {
        return (tabBarController!.viewControllers![1] as! UINavigationController).topViewController! as! LocationTableViewController
    }

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToRefreshLocationNotification()
        _ = locationTableViewController.view
        refresh(self)
    }
    
    func reloadViews() {
        mapView.removeAnnotations(mapView.annotations)
        let annotations = locations.map { MKPointAnnotation.annotation(from: $0) }
        mapView.addAnnotations(annotations)
    }
    
    func subscribeToRefreshLocationNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(locationDidStartRefresh(_:)), name: didStartRefreshLocationsNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(locationDidFinishRefresh(_:)), name: didFinishRefreshLocationsNotification, object: nil)
    }
    
    func unsubscribeToRefreshLocationNotification() {
        NotificationCenter.default.removeObserver(self, name: didStartRefreshLocationsNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: didFinishRefreshLocationsNotification, object: nil)
    }
    
    func locationDidStartRefresh(_ notification: Notification) {
        isRefreshingData = true
        overlayView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    
    func locationDidFinishRefresh(_ notification: Notification) {
        isRefreshingData = false
        overlayView.isHidden = true
        activityIndicatorView.stopAnimating()
        reloadViews()
    }
    
    @IBAction func postLocation(_ sender: Any) {
        if let accountId = appDelegate.appData?.accountId,
            let currentLocation = locations.filter({ $0.uniqueKey == accountId }).first {
            let alertController = UIAlertController(title: "", message: "User \(currentLocation.fullName) Has Already Posted a Student Location. Would You Like to Overwrite Their Location?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { (_) in
                self.performSegue(withIdentifier: postLocationSegueIdentifier, sender: currentLocation)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: postLocationSegueIdentifier, sender: nil)
        }
    }

    @IBAction func logout(_ sender: Any) {
        appDelegate.appData = nil
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refresh(_ sender: Any) {
        guard !isRefreshingData else { return }
        NotificationCenter.default.post(name: didStartRefreshLocationsNotification, object: nil)
        LocationStore.getStudentLocations { [weak self] (locations, error) in
            
            defer {
                NotificationCenter.default.post(name: didFinishRefreshLocationsNotification, object: nil)
            }
            
            if let error = error {
                self?.showAlert(title: nil, message: error.localizedDescription)
                return
            }
            
            if let locations = locations {
                self?.appDelegate.appData?.locations = locations
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == postLocationSegueIdentifier {
            guard let addLocationVC = segue.destination as? AddLocationViewController else { fatalError("Invalid View Controller") }
            if let currentLocation = sender as? StudentInformation {
                addLocationVC.currentObjectId = currentLocation.objectId
            }
        }
    }
    
    deinit {
        unsubscribeToRefreshLocationNotification()
    }
    
}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            guard let annotation = view.annotation else { return }
            mapView.deselectAnnotation(annotation, animated: true)
            guard let subtitle = annotation.subtitle ?? "",
                let url = URL(string: subtitle),
                subtitle.hasPrefix("http://") || subtitle.hasPrefix("https://"),
                UIApplication.shared.canOpenURL(url)
                else {
                    showAlert(title: nil, message: "Unsupported URL Format")
                    return
            }
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)

        }
    }
    
    
}
