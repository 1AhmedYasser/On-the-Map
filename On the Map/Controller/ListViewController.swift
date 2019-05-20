//
//  ListViewController.swift
//  On the Map
//
//  Created by Ahmed yasser on 5/14/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit
import GoogleSignIn

class ListViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    
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
    
    // Called everytime the table view appears on screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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
    
    // objective c method that adds a pin by calling the helper method (handlePopupMessage)
    @objc func addPin(){
        if Authentication.UserInfo.objectId.isEmpty {
            handlePopupMessage(message: OTMClient.postingLocationMessage, isPosting: true)
        } else {
            handlePopupMessage(message: OTMClient.overwriteLocationMessage, isPosting: false)
        }
    }
    
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
    
    // MARK: Completion Handlers
    
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
    
    // A helper method to handle the response of getting all student locationsa and dealing with errors
    func handleStudentLocationsResponse(locations: [StudentInformation],statusCode: Int, error: Error?) {
        if error != nil {
            handleErrors(appDelegate: appDelegate,statusCode: statusCode, error: error)
        } else {
            if locations.count != 0 {
                StudentModel.studentLocations = locations
                self.tableView.reloadData()
            } else {
                appDelegate.showError(controller: self,title:"Error",message: "Couldn't retrieve students location")
            }
        }
    }
}

// An extention to the list view controller that handles the table view delegate methods
extension ListViewController: UITableViewDataSource , UITableViewDelegate {
    
    // Number of table sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Number of table rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentModel.studentLocations.count
    }
    
    // Handles each cell and populate it once it appears on screen
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let studentCell = tableView.dequeueReusableCell(withIdentifier: "StudentCell")!
        
        let student = StudentModel.studentLocations[indexPath.row]
        
        if let firstName = student.firstName , let lastName = student.lastName {
            studentCell.textLabel?.text = firstName + " " + lastName
        } else {
            studentCell.textLabel?.text = "Nameless Student"
        }
        studentCell.detailTextLabel?.text = student.mediaURL
        return studentCell
    }
    
    // handles when a table cell is pressed
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentURL =  URL(string: StudentModel.studentLocations[indexPath.row].mediaURL ?? "")
        
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
