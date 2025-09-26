//
//  AuthErrors.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 26/09/25.
//

import Foundation

enum AuthError: Error, Equatable {
    case network
    case unauthorized
    case invalidCredentials     // 400 login
    case emailInUse             // 400 register
    case badStatus(Int)
    case decoding
    case noData
    case server
    case unknown(String)
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .network: return NSLocalizedString("auth.error.network", comment: "")
        case .unauthorized: return NSLocalizedString("auth.error.unauthorized", comment: "")
        case .invalidCredentials: return NSLocalizedString("auth.error.invalid_credentials", comment: "")
        case .emailInUse: return NSLocalizedString("auth.error.email_in_use", comment: "")
        case .badStatus(let code): return "HTTP \(code)"
        case .decoding: return NSLocalizedString("auth.error.decoding", comment: "")
        case .noData: return NSLocalizedString("auth.error.no_data", comment: "")
        case .server: return NSLocalizedString("auth.error.server", comment: "")
        case .unknown(let msg): return msg
        }
    }
}
