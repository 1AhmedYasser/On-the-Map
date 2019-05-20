//
//  ViewControllerExtension.swift
//  On the Map
//
//  Created by Ahmed yasser on 5/19/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation

extension UIViewController {

    
    // A helper method that handles the popup message that appears upon adding a new location
    func handlePopupMessage(message:String ,isPosting: Bool) {
        
        var Navcontroller = UINavigationController()
        Navcontroller = storyboard?.instantiateViewController(withIdentifier: "InformationPostingNavigationController") as! UINavigationController
        
        let messageVC = UIAlertController(title: "", message: message, preferredStyle: .alert)
        if !isPosting {
            messageVC.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { action in
                Navcontroller.title = "Overwite Location"
                self.present(Navcontroller,animated: true,completion: nil)
            }))
        }
        messageVC.addAction(UIAlertAction(title: "Add New", style: .default, handler: { action in
            Navcontroller.title = "Add Location"
            self.present(Navcontroller,animated: true,completion: nil)
        }))
        messageVC.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(messageVC, animated: true, completion: nil)
    }
    
    // A helper method to handle different errors
    func handleErrors(appDelegate: AppDelegate, statusCode: Int,error: Error?) {
        print(error?.localizedDescription ?? "")
        switch statusCode {
        case 400: appDelegate.showError(controller: self, title: "Error", message: "400: Bad Request")
        case 401: appDelegate.showError(controller: self, title: "Error", message: "401: Invalid Credentials")
        case 403: appDelegate.showError(controller: self, title: "Error", message: "403: Wrong email or password")
        case 405: appDelegate.showError(controller: self, title: "Error", message: "405: HttpMethod Not Allowed")
        case 410: appDelegate.showError(controller: self, title: "Error", message: "410: URL Changed")
        case 500: appDelegate.showError(controller: self, title: "Error", message: "500: Server Error")
        default:  appDelegate.showError(controller: self,title: "Error", message: error?.localizedDescription ?? "")
        }
    }
}
