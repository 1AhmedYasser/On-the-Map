//
//  AppDelegate.swift
//  On the Map
//
//  Created by Ahmed yasser on 5/14/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate  {
    
    var window: UIWindow?
    
    /* Tells the delegate that the launch process is almost done and the app is almost ready to run
     and process the results from Facebook Login and set the google client Id
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
        GIDSignIn.sharedInstance().clientID = "794530544418-03hbmp3tb19f0ktgbflml8kpce0nsl9a.apps.googleusercontent.com"
        return true
    }
    
    // Asks the delegate to open a resource identified by a URL , opens the facebook login url
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    /* Asks the delegate to open a resource specified by a URL, and provides a dictionary of launch options, opens the google login url
     */
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL?,sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    // MARK: Shared methods
    
    // A helper method that shows an Alert Box containing a given message
    // shared across different controllers
    func showError(controller: UIViewController, title: String,message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        controller.present(alertVC, animated: true, completion: nil)
    }
}

