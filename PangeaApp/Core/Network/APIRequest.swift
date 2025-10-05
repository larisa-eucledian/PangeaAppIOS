//
//  APIRequest.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 05/10/25.
//

import Foundation

enum HTTPMethod: String { case GET, POST, PUT, PATCH, DELETE }

struct APIRequest {
    var method: HTTPMethod
    var path: String
    var query: [String: String]? = nil
    var headers: [String: String]? = nil
    var body: Data? = nil           

    init(method: HTTPMethod,
         path: String,
         query: [String:String]? = nil,
         headers: [String:String]? = nil,
         jsonBody: Encodable? = nil) {
        self.method = method
        self.path = path
        self.query = query
        self.headers = headers
        if let jsonBody {
            let enc = JSONEncoder()
            enc.dateEncodingStrategy = .iso8601
            self.body = try? enc.encode(AnyEncodable(jsonBody))
        }
    }
}

/// Wrapper para permitir pasar cualquier Encodable sin genéricos en el init
private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    init(_ encodable: Encodable) { self._encode = encodable.encode }
    func encode(to encoder: Encoder) throws { try _encode(encoder) }
}
