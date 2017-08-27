//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Alfian Losari on 19/08/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import UIKit

private let presentTabBarSegueIdentifier = "PresentTabBar"

class LoginViewController: UIViewController {
    
    var appDelegate: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }
    let signupURL = URL(string: "https://auth.udacity.com/sign-up")!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
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
        emailTextField.text = ""
        passwordTextField.text = ""
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
    
    @IBAction func login(_ sender: Any) {
        view.endEditing(true)
        do {
            let (email, password) = try validateEmailAndPassword()
            showActivityIndicator(isShowing: true)
            view.isUserInteractionEnabled = false
            LoginStore.getSession(username: email, password: password) {[weak self] (session, error) in
                self?.showActivityIndicator(isShowing: false)
                self?.view.isUserInteractionEnabled = true
                if let error = error {
                    self?.showAlert(title: nil, message: error.localizedDescription)
                    return
                }
                
                // Validate Login Session Data
                guard let session = session else {
                    self?.showAlert(title: nil, message: "Failed to get login session.")
                    return
                }
                
                // Initialize app data with login session and store it in AppDelegate
                self?.appDelegate.appData = AppData(locations: [], loginSession: session)
                self?.performSegue(withIdentifier: presentTabBarSegueIdentifier, sender: nil)
            }
        } catch {
            showAlert(title: nil, message: error.localizedDescription)
            return
        }
    }
    
    @IBAction func signup(_ sender: Any) {
        UIApplication.shared.open(signupURL, options: [:], completionHandler: nil)
    }
    
    func validateEmailAndPassword() throws -> (email: String, password: String) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty && !password.isEmpty else {
                let error = NSError(domain: "Login", code: 0, userInfo: [NSLocalizedDescriptionKey: "Empty Email or Password."])
                throw error
        }
        return (email, password)
    }
    
    func showActivityIndicator(isShowing showing: Bool) {
        showing ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
    }
    
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    
}

