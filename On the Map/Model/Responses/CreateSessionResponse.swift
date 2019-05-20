//
//  createSessionResponse.swift
//  On the Map
//
//  Created by Ahmed yasser on 5/15/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation

// A codable struct that stores account and session structs
// Used as the response when a user creates a session and attempts to login
struct CreateSessionResponse: Codable {
    let account: Account
    let session: Session
}
