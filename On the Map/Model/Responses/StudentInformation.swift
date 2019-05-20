//
//  StudentLocation.swift
//  On the Map
//
//  Created by Ahmed yasser on 5/14/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation

// A codable struct that store individual locations and links downloaded from the server
struct StudentInformation: Codable {
    
    let objectId: String
    let lastName: String?
    let latitude: Double
    let mapLocation: String?
    let uniqueKey: String?
    let longitude: Double
    let firstName: String?
    let mediaURL: String?
    
    enum CodingKeys: String,CodingKey {
        case objectId
        case lastName
        case latitude
        case mapLocation = "mapString"
        case longitude
        case uniqueKey
        case firstName
        case mediaURL
    }
}
