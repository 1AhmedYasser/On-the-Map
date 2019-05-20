//
//  StudentLocationsResponse.swift
//  On the Map
//
//  Created by Ahmed yasser on 5/14/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation

// A codable struct that stores an array of student information structs
// Used as the response when getting student locations
struct StudentLocationsResponse: Codable {
    let results: [StudentInformation]
}
