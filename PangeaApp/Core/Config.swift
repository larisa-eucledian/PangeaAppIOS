//
//  Config.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 11/08/25.
//

import Foundation
enum Config {
    static let baseURL = URL(string: "https://TU_BASE_DEV")!
    static let jwtDev = "<JWT_DEV>"              // TODO: reemplazar cuando haya login (AuthManager)
    static let tenantKeyDev = "<TENANT_KEY_DEV>" // requerido en packages/transactions
}
