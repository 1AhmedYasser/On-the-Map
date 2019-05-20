//
//  Authentication.swift
//  On the Map
//
//  Created by Ahmed yasser on 5/15/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation

// A class that handles the authentication proccess of the user
class Authentication {
    
    // udacity signup URL
    static let signupURL = "https://auth.udacity.com/sign-up?next=https://classroom.udacity.com/authenticated"
    
    // Struct that contains the current logged in info and can be used throughout the app
    struct UserInfo {
        static var accountId = ""
        static var firstName = ""
        static var lastName = ""
        static var uniqueKey = ""
        static var objectId = ""
    }
    
    // Enum that stores the base url for udacity api and the session and user url's
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case session
        case user
        
        var stringValue: String {
            switch self {
            case .session: return Endpoints.base + "/session"
            case .user: return Endpoints.base + "/users/\(UserInfo.accountId)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    /* A class function that sends a POST request to udacity server along with the user email and password and upon reponse success returns the user account and session and we populate the UserInfo(accountId) with the retrieved account unique key
     */
    class func createSessionId(username: String,password: String,completionHandler: @escaping (Session?,Int,Error?) -> Void) {
        
        var request = URLRequest(url: Endpoints.session.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginRequestBody = LoginRequest(udacity: ["username": username,"password": password])
        
        request.httpBody = try! JSONEncoder().encode(loginRequestBody)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler(nil,0,error)
                }
                return
            }
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                return
            }
            
            if httpStatusCode >= 200 && httpStatusCode < 300 {
                
                let range = (5..<data!.count)
                let newData = data!.subdata(in: range)
                
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(CreateSessionResponse.self, from: newData)
                    DispatchQueue.main.async {
                        UserInfo.accountId = response.account.key
                        completionHandler(response.session,httpStatusCode,nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(nil,0,error)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    switch httpStatusCode {
                    case 400: completionHandler(nil,400,error)
                    case 401: completionHandler(nil,401,error)
                    case 403: completionHandler(nil,403,error)
                    case 405: completionHandler(nil,405,error)
                    case 410: completionHandler(nil,410,error)
                    case 500: completionHandler(nil,500,error)
                    default: completionHandler(nil,0,error)
                    }
                }
            }
        }
        task.resume()
    }
    
    /* A class function that sends a DELETE request to udacity server upon reponse success returns the user session and session id.
     */
    class func deleteSession(completionHandler: @escaping (Session?,Int,Error?) -> Void) {
        
        var request = URLRequest(url: Endpoints.session.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler(nil,0,error)
                }
                return
            }
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                return
            }
            
            if httpStatusCode >= 200 && httpStatusCode < 300 {
                let range = (5..<data!.count)
                let newData = data!.subdata(in: range)
                let decoder = JSONDecoder()
                
                do {
                    let response = try decoder.decode(DeleteSessionResponse.self, from: newData)
                    DispatchQueue.main.async {
                        completionHandler(response.session,httpStatusCode,nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(nil,0,error)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    switch httpStatusCode {
                    case 400: completionHandler(nil,400,error)
                    case 401: completionHandler(nil,401,error)
                    case 403: completionHandler(nil,403,error)
                    case 405: completionHandler(nil,405,error)
                    case 410: completionHandler(nil,410,error)
                    case 500: completionHandler(nil,500,error)
                    default: completionHandler(nil,0,error)
                    }
                }
            }
        }
        task.resume()
    }
    
    /* A class function that sends a GET request to udacity server passing the user id (retrieved from @createSessionId class function) and upon success returns a user account we populate the UserInfo(firstName,lastName,uniqueKey) with the retrieved user account info
     */
    class func getUserInfo(completionHandler: @escaping () -> Void) {
        let request = URLRequest(url: Endpoints.user.url)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {(data,response,error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler()
                }
                return
            }
            
            let range = (5..<data.count)
            let newData = data.subdata(in: range)
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(User.self, from: newData)
                DispatchQueue.main.async {
                    UserInfo.firstName = response.firstName
                    UserInfo.lastName = response.lastName
                    UserInfo.uniqueKey = response.uniqueKey
                    completionHandler()
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler()
                }
            }
            
        })
        task.resume()
    }
}
