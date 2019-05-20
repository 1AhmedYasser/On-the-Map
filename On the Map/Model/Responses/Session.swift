//
//  Session.swift
//  On the Map
//
//  Created by Ahmed yasser on 5/15/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation

// A codable struct that store session id and expiration date
struct Session: Codable {
    let id: String
    let expiration: String
}
