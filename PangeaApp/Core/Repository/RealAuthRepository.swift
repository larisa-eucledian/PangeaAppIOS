//
//  RealAuthRepository.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 05/10/25.
//

import Foundation

private struct ForgotPasswordResponseDTO: Decodable {
    let ok: Bool
}

final class RealAuthRepository: AuthRepository {
    private let api: APIClient
    private enum Path {
        static let login = "auth/local"
        static let register = "auth/local/register"
    }
    init(api: APIClient) { self.api = api }

    func login(identifier: String, password: String) async throws -> AuthSession {
        let body = LoginBodyDTO(identifier: identifier, password: password)
        let req  = APIRequest(method: .POST, path: Path.login, jsonBody: body)
        let res: AuthResponseDTO = try await api.send(req)
        return AuthSession(jwt: res.jwt, user: res.user, expiresAt: .distantFuture)
    }

    func register(username: String, email: String, password: String) async throws -> AuthSession {
        let body = RegisterBodyDTO(username: username, email: email, password: password)
        let req  = APIRequest(method: .POST, path: Path.register, jsonBody: body)
        let res: AuthResponseDTO = try await api.send(req)
        return AuthSession(jwt: res.jwt, user: res.user, expiresAt: .distantFuture)
    }
    func me(jwt: String) async throws -> AuthSession {
        if let s = SessionManager.shared.session {
            return s
        }
        throw AuthError.unauthorized
    }
    
    func forgotPassword(email: String) async throws {
        let body = ["email": email]
        let req = APIRequest(method: .POST, path: "auth/forgot-password", jsonBody: body)
        
        let _: ForgotPasswordResponseDTO = try await api.send(req)
    }
    
}
