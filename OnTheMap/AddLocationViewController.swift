//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Alfian Losari on 19/08/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import UIKit
import CoreLocation

private let presentMapLocationIdentifier = "ShowLocation"

class AddLocationViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var currentObjectId: String?
    let geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDismissKeyboardTapGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotification()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        view.endEditing(true)
    }
    
    func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        scrollView.contentSize.height = view.frame.size.height + getKeyboardHeight(notification)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        scrollView.contentSize.height = 0
    }
    
    func setupDismissKeyboardTapGestureRecognizer() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        view.addGestureRecognizer(tapGR)
    }
    
    func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func submit(_ sender: Any) {
        view.endEditing(true)
        do {
            let (location, website) = try validateLocationAndWebsite()
            showActivityIndicator(isShowing: true)
            geocoder.geocodeAddressString(location, completionHandler: {[weak self] (placemark, error) in
                DispatchQueue.main.async {
                    self?.showActivityIndicator(isShowing: false)
                    if let error = error {
                        self?.showAlert(title: nil, message: error.localizedDescription)
                        return
                    }
                    
                    guard let placemark = placemark?.first,
                        let coordinate = placemark.location?.coordinate,
                        let mapString = placemark.name
                        
                    else { return }
                    
                    
                    self?.performSegue(withIdentifier: presentMapLocationIdentifier, sender: [
                        "coordinate": coordinate,
                        "mapString": mapString,
                        "mediaURL": website
                    ])
                    
                }
            })
            
        } catch {
            showAlert(title: nil, message: error.localizedDescription)
            return
        }
        
    }
    
    func validateLocationAndWebsite() throws -> (location: String, website: String) {
        guard let location = locationTextField.text,
            let website = websiteTextField.text,
            !location.isEmpty && !website.isEmpty else {
                let error = NSError(domain: "AddLocation", code: 0, userInfo: [NSLocalizedDescriptionKey: "Empty Location or Website."])
                throw error
        }
        
        guard website.hasPrefix("http://") || website.hasPrefix("https://") else {
            let error = NSError(domain: "AddLocation", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Website URL."])
            throw error
        }

        return (location, website)
    }
    
    func showActivityIndicator(isShowing showing: Bool) {
        showing ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
        view.isUserInteractionEnabled = !showing

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == presentMapLocationIdentifier {
            guard let dictionary = sender as? [String: Any],
                let coordinate = dictionary["coordinate"] as? CLLocationCoordinate2D,
                let mapString = dictionary["mapString"] as? String,
                let mediaURL = dictionary["mediaURL"] as? String
            else { fatalError("Invalid Sender") }
            
            guard let locationMapVC = segue.destination as? AddLocationMapViewController else {
                fatalError("Invalid View Controller")
            }
            
            locationMapVC.coordinate = coordinate
            locationMapVC.mapString = mapString
            locationMapVC.mediaURL = mediaURL
            locationMapVC.currentObjectId = currentObjectId
        }
    }
    

}
