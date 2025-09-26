//
//  AuthSession.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 26/09/25.
//

import Foundation

struct AuthSession: Codable, Equatable {
    let jwt: String
    let user: AuthUser
    /// *Opcional en mock; cuando ya conecte al backend lo puedo derivar del JWT (exp).
    let expiresAt: Date?

    var isExpired: Bool {
        if let exp = expiresAt { return exp <= Date() }
        // Mientras no haya exp real, lo considero válido si hay token no vacío (modo mock).
        return jwt.isEmpty
    }
}
