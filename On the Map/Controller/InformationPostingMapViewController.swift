//
//  InformationPostingMapViewController.swift
//  On the Map
//
//  Created by Ahmed yasser on 5/15/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingMapViewController: UIViewController, MKMapViewDelegate {
    
    // Variables: to be passed from Information posting view controller
    var firstName: String!
    var lastName: String!
    var locationLat: Double!
    var locationLong: Double!
    var mediaURL: String!
    var mapLocation: String!
    
    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // A refrence to the app delegate , used to share data between different controllers
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* sets up the bar button items and navigation item title
         and set a pin on the map with given annotation values
         */
        setupController()
    }
    
    // handles when the finish button is pressed , either post or overwite the location
    @IBAction func submitLocation(_ sender: Any) {
        let locationRequest = PostingLocationRequest(uniqueKey: Authentication.UserInfo.uniqueKey, firstName: firstName, lastName: lastName, mapLocation: mapLocation, mediaURL: mediaURL, latitude: locationLat, longitude: locationLong)
        if navigationController?.title == "Overwite Location" {
            OTMClient.overwriteStudentLocation(LocationRequest: locationRequest, completionHandler: handleOverwriteLocationResponse(statusCode:error:))
        } else {
            OTMClient.postStudentLocation(LocationRequest: locationRequest, completionHandler: handlePostLocationResponse(statusCode:error:))
        }
    }
    
    // dismiss the information posting view
    @objc func cancel (){
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helper Methods
    /* A helper method that sets up the bar button items and navigation item title
     and set a pin on the map with given annotation values
     */
    func setupController() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        
        navigationItem.title = navigationController?.title
        
        let span = MKCoordinateSpan(latitudeDelta: 0.020, longitudeDelta: 0.020)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locationLat, longitude: locationLong), span: span)
        mapView.setRegion(region, animated: true)
        let coordinate = CLLocationCoordinate2D(latitude: locationLat, longitude: locationLong)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(firstName ?? "") \(lastName ?? "")"
        annotation.subtitle = mediaURL
        self.mapView.addAnnotation(annotation)
    }
    
    // MARK: Completion Handlers
    
    // A helper method to handle the response of posting a student location and dealing with errors
    func handlePostLocationResponse(statusCode:Int, error: Error?){
        if error != nil {
            handleErrors(appDelegate: appDelegate, statusCode: statusCode, error: error)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // A helper method to handle the response of overwriting a student location and dealing with errors
    func handleOverwriteLocationResponse(statusCode:Int, error: Error?){
        if error != nil {
            handleErrors(appDelegate: appDelegate, statusCode: statusCode, error: error)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: Delegate methods
    
    // A method that setup the map pin
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
    
    // A method that setup the map pin actions
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let subtitleURL = view.annotation?.subtitle! {
                let studentURL =  URL(string: subtitleURL)
                if let studentURL = studentURL {
                    if UIApplication.shared.canOpenURL(studentURL) {
                        UIApplication.shared.open(studentURL, options: [:], completionHandler: nil)
                    } else {
                        appDelegate.showError(controller: self,title: "Error",message: "Invalid URL")
                    }
                } else {
                    appDelegate.showError(controller: self,title: "Error",message: "Invalid URL")
                }
            }
        }
    }
}
