//
//  MapViewController.swift
//  On the Map
//
//  Created by Ahmed yasser on 5/14/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit
import MapKit
import GoogleSignIn

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // logout button
    var logoutButton: UIBarButtonItem!
    
    // A refrence to the app delegate , used to share data between different controllers
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sets up the bar button items and request the students location
        setupController()
    }
    
    // MARK: Helper methods
    
    // A helper method that setup the bar button items and request the recent students location
    func setupController() {
        let addPinBarButton =  UIBarButtonItem (image: UIImage(named: "AddPinIcon"), style: .plain
            , target: self, action: #selector(addPin))
        
        let refreshBarButton =  UIBarButtonItem (image: UIImage(named: "RefreshIcon"), style: .plain
            , target: self, action: #selector(refresh))
        
        logoutButton =  UIBarButtonItem (title: "Logout ", style: .plain
            , target: self, action: #selector(logout))
        navigationItem.leftBarButtonItem = logoutButton
        
        navigationItem.rightBarButtonItems = [addPinBarButton,refreshBarButton]
        navigationItem.title = "On the Map"
        
        OTMClient.requestStudentsLocation(completionHandler: handleStudentLocationsResponse(locations:statusCode:error:))
    }
    
    // MARK: Bar Buttons Actions
    
    // objective c method that refresh the students location
    @objc func refresh(){
        OTMClient.requestStudentsLocation(completionHandler: handleStudentLocationsResponse(locations:statusCode:error:))
    }
    
    // objective c method that initiate logout
    @objc func logout(){
        logoutButton.isEnabled = false
        if FBSDKAccessToken.current() != nil {
            logoutButton.isEnabled = true
            let manager = FBSDKLoginManager()
            manager.logOut()
            self.dismiss(animated: true, completion: nil)
        } else {
            if Authentication.UserInfo.accountId.isEmpty {
                logoutButton.isEnabled = true
                GIDSignIn.sharedInstance().signOut()
                self.dismiss(animated: true, completion: nil)
            } else {
                Authentication.deleteSession(completionHandler: handleDeleteSessionResponse(session:statusCode:error:))
            }
        }
    }
    
    // objective c method that adds a pin by calling the helper method (handlePopupMessage)
    @objc func addPin(){
        
        if Authentication.UserInfo.objectId.isEmpty {
            handlePopupMessage(message: OTMClient.postingLocationMessage, isPosting: true)
        } else {
            handlePopupMessage(message: OTMClient.overwriteLocationMessage, isPosting: false)
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
    
    // MARK: Completion Handlers
    
    // A helper method to handle the response of getting all student locationsa and dealing with errors
    func handleStudentLocationsResponse(locations: [StudentInformation],statusCode: Int,error: Error?) {
        
        if error != nil {
            handleErrors(appDelegate: appDelegate,statusCode: statusCode, error: error)
        } else {
            if locations.count != 0 {
                StudentModel.studentLocations = locations
                var annotations = [MKPointAnnotation]()
                
                for studentLocation in locations {
                    
                    let latitude = CLLocationDegrees(studentLocation.latitude)
                    let longitude = CLLocationDegrees(studentLocation.longitude)
                    
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    
                    let firstName = studentLocation.firstName ?? ""
                    let lastName = studentLocation.lastName ?? ""
                    let mediaURL = studentLocation.mediaURL
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(firstName) \(lastName)"
                    annotation.subtitle = mediaURL
                    
                    annotations.append(annotation)
                }
                self.mapView.addAnnotations(annotations)
            } else {
                appDelegate.showError(controller: self,title:"Error",message: "Couldn't retrieve students location")
            }
        }
    }
    
    // A helper method to handle the response of deleting session and dealing with errors
    func handleDeleteSessionResponse(session: Session?,statusCode: Int,error: Error?) {
        
        if error != nil {
            handleErrors(appDelegate: appDelegate,statusCode: statusCode,error: error)
        } else {
            if let _ = session {
                Authentication.UserInfo.accountId = ""
                self.dismiss(animated: true, completion: nil)
            } else {
                logoutButton.isEnabled = true
                handleErrors(appDelegate: appDelegate,statusCode: statusCode,error: error)
            }
        }
    }
    
    
}
