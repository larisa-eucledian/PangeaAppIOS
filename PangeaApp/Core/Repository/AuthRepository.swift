//
//  AuthRepository.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 26/09/25.
//

import Foundation

protocol AuthRepository {
    func login(identifier: String, password: String) async throws -> AuthSession

    func register(username: String, email: String, password: String) async throws -> AuthSession

    func me(jwt: String) async throws -> AuthSession
    
    func forgotPassword(email: String) async throws
}
