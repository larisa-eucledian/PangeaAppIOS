//
//  APIAuthModels.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 05/10/25.
//

import Foundation

// Respuesta común de login/register
struct AuthResponseDTO: Decodable {
    let jwt: String
    let user: AuthUser
}

// Login (Strapi local): identifier = email o username
struct LoginBodyDTO: Encodable {
    let identifier: String
    let password: String
}

// Register (Strapi local)
struct RegisterBodyDTO: Encodable {
    let username: String
    let email: String
    let password: String
}

