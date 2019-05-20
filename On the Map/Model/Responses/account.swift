//
//  Account.swift
//  On the Map
//
//  Created by Ahmed yasser on 5/15/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation

// A codable struct that store if the user is registered as a boolean and the user unique key
struct Account: Codable {
    let registered: Bool
    let key: String
}
