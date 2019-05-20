//
//  DeleteSessionResponse.swift
//  On the Map
//
//  Created by Ahmed yasser on 5/15/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation

// A codable struct that store session struct
// Used as the response when a user delete a session and attempts to logout
struct DeleteSessionResponse: Codable {
    let session: Session
}
