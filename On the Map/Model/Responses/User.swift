//
//  User.swift
//  On the Map
//
//  Created by Ahmed yasser on 5/15/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation

// A codable struct that store user's first name , last name and unique key
struct User: Codable {
    
    let firstName: String
    let lastName: String
    let uniqueKey: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case uniqueKey = "key"
    }
}
