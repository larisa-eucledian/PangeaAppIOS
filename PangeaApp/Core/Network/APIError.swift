//
//  APIError.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 05/10/25.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case httpStatus(code: Int, body: String?)
    case decoding(Error)
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .httpStatus(let code, _): return "HTTP \(code)"
        case .decoding: return "Decoding error."
        case .network: return "Network transport error."
        }
    }
}

