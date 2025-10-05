//
//  Config.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 11/08/25.
//

import Foundation
enum Config {
    static let baseURL = URL(string: "https://e950737f306e.ngrok-free.app/api")!
    static let jwtDev = "<JWT_DEV>"              //requests con token? (AuthManager)
    static let tenantKeyDev = "<TENANT_KEY_DEV>"
}
