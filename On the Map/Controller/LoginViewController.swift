//
//  LoginViewController.swift
//  On the Map
//
//  Created by Ahmed yasser on 5/14/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController , UITextFieldDelegate,  FBSDKLoginButtonDelegate , GIDSignInUIDelegate , GIDSignInDelegate {
    
    // Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stackView: UIStackView!
    
    // Facebook login button with reading permissions
    let facebookLoginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()
    
    // Google login button
    var GsignInButton: GIDSignInButton!
    
    // A refrence to the app delegate , used to share data between different controllers
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set textFields delegates
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // A helper method that sets up the login screen
        setupLogin()
    }
    
    // MARK: IBActions methods
    
    // Checks for empty fields and then handles when the login button is pressed
    @IBAction func LoginViaPassedInfo(_ sender: UIButton) {
        
        if  emailTextField.text?.isEmpty ?? true {
            appDelegate.showError(controller: self,title: "Empty Field",message: "Please supply an email")
            return
        }
        
        if  passwordTextField.text?.isEmpty ?? true {
            appDelegate.showError(controller: self,title: "Empty Field", message: "Please supply a password")
            return
        }
        
        setLoggingIn(true)
        Authentication.createSessionId(username: emailTextField.text ?? "", password: passwordTextField.text ?? "", completionHandler: handleCreateSessionResponse(session:statusCode:error:))
        
    }
    
    // Handles when the signup button is pressed and open the signupURL if possible
    @IBAction func signup(_ sender: Any) {
        let signupURL = URL(string:Authentication.signupURL)
        if let signupURL = signupURL {
            if UIApplication.shared.canOpenURL(signupURL) {
                UIApplication.shared.open(signupURL, options: [:], completionHandler: nil)
            } else {
                appDelegate.showError(controller: self,title: "Error",message: "Invalid URL")
            }
        } else {
            appDelegate.showError(controller: self,title: "Error",message: "Invalid URL")
        }
    }
    
    // MARK: Delegate methods
    
    // Handles when the facebook login is proccessed
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            appDelegate.showError(controller: self,title: "Error", message: "Cannot login via facebook")
        } else {
            if FBSDKAccessToken.current() != nil {
                loginToApp()
            }
        }
    }
    
    // Handles when the facebook logs out
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {}
    
    // handles when the google login is proccessed
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if (error == nil) {
            loginToApp()
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    // Hides the keyboard when the return button is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    // MARK: Helper methods
    
    // A method that initialize a tab contoller with ruse identifier and present it
    func loginToApp() {
        var Tabcontroller = UITabBarController()
        Tabcontroller = storyboard?.instantiateViewController(withIdentifier: "StudentLocationsTabbedView") as! UITabBarController
        present(Tabcontroller, animated: true, completion: nil)
    }
    
    // A method that changes the state of the login screen upon login activity
    func setLoggingIn(_ logginIn: Bool) {
        if logginIn {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        emailTextField.isEnabled = !logginIn
        passwordTextField.isEnabled = !logginIn
        loginButton.isEnabled = !logginIn
        facebookLoginButton.isEnabled = !logginIn
    }
    
    // A method that sets up the services buttons and clear the text fields
    func setupLogin() {
        facebookLoginButton.frame = CGRect(x: stackView.bounds.origin.x, y: stackView.bounds.origin.y, width: stackView.frame.width, height: 50)
        facebookLoginButton.clipsToBounds = true
        
        stackView.addArrangedSubview(facebookLoginButton)
        facebookLoginButton.delegate = self
        
        GsignInButton = GIDSignInButton(frame: CGRect.init(x: stackView.bounds.origin.x,y: stackView.bounds.origin.y,width: stackView.frame.width,height: 50))
        stackView.addArrangedSubview(GsignInButton)
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    // MARK: Completion Handlers
    
    // A helper method to handle the response of creating a session and dealing with errors
    func handleCreateSessionResponse(session: Session?,statusCode: Int,error: Error?) {
        
        if error != nil {
            setLoggingIn(false)
            handleErrors(appDelegate: appDelegate,statusCode: statusCode,error: error)
        } else {
        setLoggingIn(false)
        if let _ = session {
            Authentication.getUserInfo(completionHandler: handleUserInfoResponse)
            loginToApp()
        } else {
            setLoggingIn(false)
            handleErrors(appDelegate: appDelegate,statusCode: statusCode,error: error)
        }
    }
}
    // A helper method to handle the response of getting user info
    func handleUserInfoResponse() {
        OTMClient.requestCurrentStudentLocation()
    }
    
}
