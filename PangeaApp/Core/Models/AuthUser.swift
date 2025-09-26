//
//  AuthUser.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 26/09/25.
//

import Foundation

struct AuthUser: Codable, Equatable {
    let id: Int
    let username: String
    let email: String
    let confirmed: Bool?
    let blocked: Bool?
}
