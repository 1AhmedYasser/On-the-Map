//
//  InformationPostingViewController.swift
//  PinSample
//
//  Created by Ahmed yasser on 5/15/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController , UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mediaURLTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // A refrence to the app delegate , used to share data between different controllers
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set textFields delegates
        locationTextField.delegate = self
        mediaURLTextField.delegate = self
        
        // handles when the keyboard appears
        subscribeToKeyboardNotifications()
        
        // sets up the bar button items and navigation item title
        setupController()
    }
    
    // MARK: View will appear
    // subscribe to keyboard notfications
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          subscribeToKeyboardNotifications()
    }
    
    // MARK: View will disappear
    // unsubscribe from keyboard notfications
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // A helper method that sets up the bar button items and navigation item title
    func setupController() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        
        navigationItem.title = navigationController?.title
    }
    
    // dismiss the information posting view
    @objc func cancel (){
        self.dismiss(animated: true, completion: nil)
    }
    
    // handles when the find Location button is pressed and initaite geocoding
    @IBAction func findLocation(_ sender: Any) {
        var coordinates = CLLocationCoordinate2D()
        
        if  locationTextField.text?.isEmpty ?? true {
            appDelegate.showError(controller: self,title: "Empty Field",message: "Please supply a Location")
            return
        }
        
        if  mediaURLTextField.text?.isEmpty ?? true {
            appDelegate.showError(controller: self,title: "Empty Field", message: "Please supply a media URL")
            return
        }
        
        setFindingLocation(true)
        
        let geoCoder = CLGeocoder()
        let address = locationTextField.text!
        geoCoder.geocodeAddressString(address, completionHandler: {(placemarks,error) in
            self.setFindingLocation(false)
            if let placemark = placemarks?.first {
                coordinates = placemark.location!.coordinate
                let mapView = self.storyboard?.instantiateViewController(withIdentifier: "InformationPostingMapVC") as! InformationPostingMapViewController
                
                mapView.firstName = Authentication.UserInfo.firstName
                mapView.lastName = Authentication.UserInfo.lastName
                mapView.locationLat = coordinates.latitude
                mapView.locationLong = coordinates.longitude
                mapView.mediaURL = self.mediaURLTextField.text!
                mapView.mapLocation = self.locationTextField.text!
                self.navigationController!.pushViewController(mapView, animated: true)
            } else {
                if error!.localizedDescription.contains("2") {
                    self.appDelegate.showError(controller: self,title: "Error",message: "Check Internet Connectivity")
                } else {
                    self.appDelegate.showError(controller: self,title: "Error",message: "Location Not Found")
                }
            }
        })
        
    }
    
     // A method that changes the state of the information posting screen upon geocoding activity
    func setFindingLocation(_ findingLocation: Bool) {
        if findingLocation {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        locationTextField.isEnabled = !findingLocation
        mediaURLTextField.isEnabled = !findingLocation
        findLocationButton.isEnabled = !findingLocation
    }
    
    // Hides the keyboard when the return button is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    // MARK: keyboard Settings
    // Activate keyboard notifications on keyboard presence and absence
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Disables keyboard notifications
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    // if the bottom text field is the first responder then shift the view up
    @objc func keyboardWillShow(_ notification:Notification) {
        if mediaURLTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    // if the keyboard is dismissed then shift the view back to its original state
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    // Returns the keyboard height as a float value
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
}
