//
//  APIClient.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 05/10/25.
//

import Foundation

protocol APIClient {
    func send<T: Decodable>(_ request: APIRequest) async throws -> T
    func sendVoid(_ request: APIRequest) async throws
}

final class DefaultAPIClient: APIClient {
    private let baseURL: URL
    private let urlSession: URLSession
    private let decoder: JSONDecoder
    private let tokenProvider: () -> String?

    init(baseURL: URL,
         urlSession: URLSession = .shared,
         tokenProvider: @escaping () -> String? = { nil }) {
        self.baseURL = baseURL
        self.urlSession = urlSession
        self.tokenProvider = tokenProvider

        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        self.decoder = dec
    }

    func send<T: Decodable>(_ request: APIRequest) async throws -> T {
        let (data, response) = try await urlSession.data(for: try makeURLRequest(from: request))
        try handleAuthSideEffects(response: response, data: data)
        return try decode(data)
    }

    func sendVoid(_ request: APIRequest) async throws {
        let (data, response) = try await urlSession.data(for: try makeURLRequest(from: request))
        try handleAuthSideEffects(response: response, data: data)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw mapHTTPError(response: response, data: data)
        }
    }

    // MARK: - Helpers
    private func makeURLRequest(from req: APIRequest) throws -> URLRequest {
        guard var comps = URLComponents(
            url: baseURL.appendingPathComponent(req.path),
            resolvingAgainstBaseURL: false
        ) else { throw APIError.invalidURL }

        if let q = req.query, !q.isEmpty {
            comps.queryItems = q.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = comps.url else { throw APIError.invalidURL }

        var urlReq = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        urlReq.httpMethod = req.method.rawValue

        var headers = req.headers ?? [:]
        if headers["Content-Type"] == nil, req.body != nil {
            headers["Content-Type"] = "application/json"
        }
        if headers["Accept"] == nil { headers["Accept"] = "application/json" }
        if let token = tokenProvider(), !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        headers["X-Tenant-API-Key"] = Config.tenantAPIKey
        
        for (k,v) in headers { urlReq.setValue(v, forHTTPHeaderField: k) }
        urlReq.httpBody = req.body
        return urlReq
    }

    private func handleAuthSideEffects(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { return }
        if (200..<300).contains(http.statusCode) { return }
        if http.statusCode == 401 {
            // Cierra sesión si el server responde 401
            SessionManager.shared.clear()
            throw AuthError.unauthorized
        }
        throw mapHTTPError(response: response, data: data)
    }

    private func mapHTTPError(response: URLResponse, data: Data) -> Error {
        guard let http = response as? HTTPURLResponse else {
            return APIError.network(URLError(.badServerResponse))
        }
        let bodySnippet = String(data: data, encoding: .utf8)
        return APIError.httpStatus(code: http.statusCode, body: bodySnippet)
    }

    private func decode<T: Decodable>(_ data: Data) throws -> T {
        do { return try decoder.decode(T.self, from: data) }
        catch { throw APIError.decoding(error) }
    }
}
