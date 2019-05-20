//
//  OTMClient.swift
//  On the Map
//
//  Created by Ahmed yasser on 5/14/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation

// A class that handles the user client requests.
class OTMClient {
    
    // static information about the api and messages
    static let parseAppId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    static let overwriteLocationMessage = "You Have Already Posted a Student Location. Would You Like to Overrite Your Current Location?"
    static let postingLocationMessage = "Add New Location?"
    
    // Enum that stores the base url for udacity parse api and requests url's
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1/StudentLocation"
        
        case getStudentLocation
        case getCurrentStudentLocation
        case updateStudentLocation
        
        var stringValue: String {
            switch self {
            case .getStudentLocation: return Endpoints.base + "?limit=100&order=-updatedAt"
            case .getCurrentStudentLocation: return Endpoints.base + "?where=%7B%22uniqueKey%22%3A%22\(Authentication.UserInfo.uniqueKey)%22%7D"
            case .updateStudentLocation: return Endpoints.base + "/\(Authentication.UserInfo.objectId)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    /* A class function that gets the most recent 100 student locations using a get request to the udacity parse api.
     */
    class func requestStudentsLocation(completionHandler: @escaping ([StudentInformation],Int,Error?) -> Void) {
        
        _ = getRequest(url: Endpoints.getStudentLocation.url, responseType: StudentLocationsResponse.self, completion: {(response,statusCode,error) in
            
            if let response = response {
                completionHandler(response.results,statusCode,nil)
            } else {
                completionHandler([],statusCode,error)
            }
        })
    }
    
    /* A class function that gets the current student location using a get request setting the object id in the Authentication user info struct to the retrived object id
     */
    class func requestCurrentStudentLocation() {
        
        _ = getRequest(url: Endpoints.getCurrentStudentLocation.url, responseType: StudentLocationsResponse.self, completion: {(response,statusCode,error) in
            
            if response != nil {
                if response!.results.count != 0 {
                    Authentication.UserInfo.objectId = response!.results[0].objectId
                }
            }
        })
    }
    
    /* A class function that post a student location using a post request given the posting location request
     */
    class func postStudentLocation(LocationRequest: PostingLocationRequest, completionHandler: @escaping (Int,Error?) -> Void) {
        
        _ = postOrPUTRequest(url: Endpoints.getStudentLocation.url, body: LocationRequest, method: "POST", completion: {(statusCode,error) in
            
            if error != nil {
                completionHandler(statusCode,error)
            } else {
                completionHandler(statusCode,nil)
            }
        })
    }
    
    /* A class function that overwrites a student location using a post request given the object id
     for the current user stored Authentication user info struct and the posting location request
     */
    class func overwriteStudentLocation(LocationRequest: PostingLocationRequest, completionHandler: @escaping (Int,Error?) -> Void) {
        
        _ = postOrPUTRequest(url: Endpoints.updateStudentLocation.url, body: LocationRequest, method: "PUT", completion: {(statusCode,error) in
            
            if error != nil {
                completionHandler(statusCode,error)
            } else {
                completionHandler(statusCode,nil)
            }
        })
    }
    
    // A class function that handles GET requests
    class func getRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?,Int, Error?) -> Void) {
        
        var request = URLRequest(url: url)
        request.addValue(parseAppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {(data,response,error) in
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil,0,error)
                }
                return
            }
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                return
            }
            
            if httpStatusCode >= 200 && httpStatusCode < 300 {
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(ResponseType.self, from: data!)
                    DispatchQueue.main.async {
                        completion(response,httpStatusCode,nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil,0,error)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    switch httpStatusCode {
                    case 400: completion(nil,400,error)
                    case 401: completion(nil,401,error)
                    case 403: completion(nil,403,error)
                    case 405: completion(nil,405,error)
                    case 410: completion(nil,410,error)
                    case 500: completion(nil,500,error)
                    default: completion(nil,0,error)
                    }
                }
            }
        })
        
        task.resume()
    }
    
    // A class function that handles POST and PUT requests
    class func postOrPUTRequest(url: URL,body: PostingLocationRequest, method: String, completion: @escaping (Int, Error?) -> Void){
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue(parseAppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = PostingLocationRequest(uniqueKey: body.uniqueKey, firstName: body.firstName, lastName: body.lastName, mapLocation: body.mapLocation, mediaURL: body.mediaURL, latitude: body.latitude, longitude: body.longitude)
        
        request.httpBody = try! JSONEncoder().encode(requestBody)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(0,error)
                }
                return
            }
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                return
            }
            if httpStatusCode >= 200 && httpStatusCode < 300 {
                DispatchQueue.main.async {
                    completion(httpStatusCode,nil)
                }
            } else {
                DispatchQueue.main.async {
                    switch httpStatusCode {
                    case 400: completion(400,error)
                    case 401: completion(401,error)
                    case 403: completion(403,error)
                    case 405: completion(405,error)
                    case 410: completion(410,error)
                    case 500: completion(500,error)
                    default: completion(0,error)
                    }
                }
            }
        }
        task.resume()
    }
}
