//
//  SessionRequest.swift
//  On the Map
//
//  Created by Ahmed yasser on 5/15/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation

// A codable struct that contains a udacity dictonary that stores the passed username and password
// Used as the request body in creating a new session
struct LoginRequest: Codable {
    
    let udacity: [String:String]
}

