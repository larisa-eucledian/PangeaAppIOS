//
//  SessionManager.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 26/09/25.
//

import Foundation

final class SessionManager {
    static let shared = SessionManager()
    static let sessionDidChange = Notification.Name("SessionDidChange")

    private let jwtKey = "auth.jwt"
    private let expKey = "auth.exp" // ISO8601 string
    private let userKey = "auth.user" // JSON serialized AuthUser

    private(set) var session: AuthSession? = nil

    private let iso = ISO8601DateFormatter()

    private init() {}

    var isValid: Bool {
        guard let s = session else { return false }
        return !s.isExpired && !s.jwt.isEmpty
    }

    func loadFromKeychain() {
        do {
            let jwt = try KeychainService.read(account: jwtKey).flatMap { String(data: $0, encoding: .utf8) } ?? ""
            let expStr = try KeychainService.read(account: expKey).flatMap { String(data: $0, encoding: .utf8) }
            let exp = expStr.flatMap { iso.date(from: $0) }

            if !jwt.isEmpty {
                // Load user data from keychain
                if let userData = try? KeychainService.read(account: userKey),
                   let user = try? JSONDecoder().decode(AuthUser.self, from: userData) {
                    self.session = AuthSession(jwt: jwt, user: user, expiresAt: exp)
                } else {
                    // Fallback: create placeholder user if user data not found
                    self.session = AuthSession(jwt: jwt, user: AuthUser(id: -1, username: "", email: "", confirmed: nil, blocked: nil), expiresAt: exp)
                }
            } else {
                self.session = nil
            }
        } catch {
            self.session = nil
        }
        NotificationCenter.default.post(name: Self.sessionDidChange, object: nil)
    }

    func save(session: AuthSession) {
        do {
            try KeychainService.save(Data(session.jwt.utf8), account: jwtKey)

            // Save user data
            if let userData = try? JSONEncoder().encode(session.user) {
                try KeychainService.save(userData, account: userKey)
            }

            if let exp = session.expiresAt {
                try KeychainService.save(Data(ISO8601DateFormatter().string(from: exp).utf8), account: expKey)
            } else {
                KeychainService.delete(account: expKey)
            }
            self.session = session
            NotificationCenter.default.post(name: Self.sessionDidChange, object: nil)
        } catch {
            clear()
        }
    }

    func clear() {
        KeychainService.delete(account: jwtKey)
        KeychainService.delete(account: expKey)
        KeychainService.delete(account: userKey)
        session = nil
        NotificationCenter.default.post(name: Self.sessionDidChange, object: nil)
    }
}
