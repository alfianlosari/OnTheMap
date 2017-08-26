//
//  LocationTableViewController.swift
//  OnTheMap
//
//  Created by Alfian Losari on 19/08/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import UIKit
import SafariServices

private let postLocationSegueIdentifier = "PostLocation"
private let reuseIdentifier = "LocationCell"

class LocationTableViewController: UIViewController, RefreshViewControllerType {
    
    var appDelegate: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }
    var locations: [StudentInformation] { return appDelegate.locations }
    var isRefreshingData = false
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToRefreshLocationNotification()
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
        activityIndicatorView.startAnimating()
    }
    
    func locationDidFinishRefresh(_ notification: Notification) {
        isRefreshingData = false
        activityIndicatorView.stopAnimating()
        tableView.reloadData()
    }
    
    @IBAction func postLocation(_ sender: Any) {
        if let accountId = appDelegate.accountId,
            let currentLocation = appDelegate.locations.filter({ $0.uniqueKey == accountId }).first {
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
        appDelegate.loginSession = nil
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refresh(_ sender: Any) {
        guard !isRefreshingData else { return }
        NotificationCenter.default.post(name: didStartRefreshLocationsNotification, object: nil)
        LocationStore.getStudentLocations { [weak self] (locations, error) in
            if let error = error {
                self?.showAlert(title: nil, message: error.localizedDescription)
                return
            }
            
            if let locations = locations {
                self?.appDelegate.locations = locations
            }
            
            NotificationCenter.default.post(name: didFinishRefreshLocationsNotification, object: nil)
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

extension LocationTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationTableViewCell
        cell.setup(location: locations[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = locations[indexPath.row]
        guard location.mediaURL.hasPrefix("http://") || location.mediaURL.hasPrefix("https://"),
            let url = URL(string: locations[indexPath.row].mediaURL) else {
                showAlert(title: nil, message: "Unsupported URL Format")
                return
        
        }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    
}

