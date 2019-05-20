//
//  PostingLocationRequest.swift
//  On the Map
//
//  Created by Ahmed yasser on 5/15/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation

// A codable struct that contains a student information to be posted on the server
// Used as the request body in posting or overwritng existing student location
struct PostingLocationRequest: Codable {
    
    let uniqueKey: String
    let firstName: String?
    let lastName: String?
    let mapLocation: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String,CodingKey {
        case uniqueKey
        case firstName
        case lastName
        case mapLocation = "mapString"
        case mediaURL
        case latitude
        case longitude
    }
}
