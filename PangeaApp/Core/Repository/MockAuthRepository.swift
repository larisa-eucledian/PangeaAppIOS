//
//  MockAuthRepository.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 26/09/25.
//

import Foundation
import CryptoKit

final class MockAuthRepository: AuthRepository {

    struct MockUser: Codable, Equatable {
        let id: Int
        let username: String
        let email: String
        let passwordHash: String
    }

    // MARK: - Config
    private let ttlSeconds: TimeInterval
    private let now: () -> Date

    // MARK: - State (memoria)
    private var usersByEmail: [String: MockUser] = [:]
    private var usersByUsername: [String: MockUser] = [:]
    private var nextUserId: Int = 1
    private var activeTokens: [String: (user: MockUser, expiresAt: Date)] = [:]

    // MARK: - Init
    // expiración de 1 hora para pruebas
    init(ttlSeconds: TimeInterval = 60 * 60, now: @escaping () -> Date = Date.init) {
        self.ttlSeconds = ttlSeconds
        self.now = now

        // Usuario demo opcional
        let demo = MockUser(
            id: nextUserId,
            username: "demo",
            email: "demo@pangea.app",
            passwordHash: Self.hash("pangea123")
        )
        nextUserId += 1
        usersByEmail[demo.email.lowercased()] = demo
        usersByUsername[demo.username.lowercased()] = demo
    }

    // MARK: - Public (AuthRepository)
    func login(identifier: String, password: String) async throws -> AuthSession {
        try await Task.sleep(nanoseconds: 150_000_000) // Simula latencia

        guard let user = findUser(identifier: identifier) else {
            throw AuthError.invalidCredentials
        }
        guard verify(password: password, hash: user.passwordHash) else {
            throw AuthError.invalidCredentials
        }
        return issueSession(for: user)
    }

    func register(username: String, email: String, password: String) async throws -> AuthSession {
        try await Task.sleep(nanoseconds: 200_000_000)

        // Validaciones básicas (mock)
        guard password.count >= 8 else { throw AuthError.invalidCredentials }
        let emailKey = email.lowercased()
        let usernameKey = username.lowercased()

        if usersByEmail[emailKey] != nil { throw AuthError.emailInUse }
        if usersByUsername[usernameKey] != nil { throw AuthError.emailInUse }

        let user = MockUser(
            id: nextUserId,
            username: username,
            email: email,
            passwordHash: Self.hash(password)
        )
        nextUserId += 1
        usersByEmail[emailKey] = user
        usersByUsername[usernameKey] = user

        return issueSession(for: user)
    }

    func me(jwt: String) async throws -> AuthSession {
        try await Task.sleep(nanoseconds: 80_000_000)

        guard let entry = activeTokens[jwt] else {
            throw AuthError.unauthorized
        }
        // Checa expiración
        if entry.expiresAt <= now() {
            activeTokens.removeValue(forKey: jwt)
            throw AuthError.unauthorized
        }
        // Devuelve sesión con el mismo JWT y la fecha de expiración vigente
        let authUser = AuthUser(
            id: entry.user.id,
            username: entry.user.username,
            email: entry.user.email,
            confirmed: true,
            blocked: false
        )
        return AuthSession(jwt: jwt, user: authUser, expiresAt: entry.expiresAt)
    }

    // MARK: - Helpers
    private func issueSession(for user: MockUser) -> AuthSession {
        let exp = now().addingTimeInterval(ttlSeconds)
        let jwt = "mock.\(UUID().uuidString.lowercased())"
        activeTokens[jwt] = (user: user, expiresAt: exp)

        let authUser = AuthUser(
            id: user.id,
            username: user.username,
            email: user.email,
            confirmed: true,
            blocked: false
        )
        return AuthSession(jwt: jwt, user: authUser, expiresAt: exp)
    }

    private func findUser(identifier: String) -> MockUser? {
        let key = identifier.lowercased()
        return usersByEmail[key] ?? usersByUsername[key]
    }

    private func verify(password: String, hash: String) -> Bool {
        Self.hash(password) == hash
    }

    private static func hash(_ value: String) -> String {
        let digest = Insecure.SHA1.hash(data: Data(value.utf8))
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
