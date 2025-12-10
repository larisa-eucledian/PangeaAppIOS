//
//  RealESimsRepository.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 22/11/25.
//

import Foundation

final class RealESimsRepository: ESimsRepository {
    
    private let api: APIClient
    
    private enum Path {
        static let esims = "esims"
        static let activate = "esim/activate"
        static func usage(esimId: String) -> String {
            return "esim/usage/\(esimId)"
        }
    }
    
    init(api: APIClient = AppDependencies.shared.apiClient) {
        self.api = api
    }
    
    // MARK: - ESimsRepository Protocol
    
    func fetchESims() async throws -> [ESimRow] {
        let req = APIRequest(
            method: .GET,
            path: Path.esims
        )
        
        // API returns { "data": [ESimDTO] }
        let response: ESimsResponseDTO = try await api.send(req)
        return response.data.map { $0.toDomain() }
    }
    
    func activate(esimId: String) async throws -> ESimRow {
        let requestBody = ActivateESimRequestDTO(esim_id: esimId)
        
        let req = APIRequest(
            method: .POST,
            path: Path.activate,
            jsonBody: requestBody
        )
        
        let response: ActivateESimResponseDTO = try await api.send(req)
        return response.esim.toDomain()
    }
    
    func fetchUsage(esimId: String) async throws -> ESimUsage {
        let req = APIRequest(
            method: .GET,
            path: Path.usage(esimId: esimId)
        )
        
        let response: ESimUsageResponseDTO = try await api.send(req)
        return response.toDomain()
    }
}
