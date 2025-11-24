//
//  RealPlansRepository.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 22/11/25.
//

import Foundation

final class RealPlansRepository: PlansRepository {
    
    private let api: APIClient
    
    private enum Path {
        static let countries = "countries"
        static let packages = "tenant/packages"
    }
    
    init(api: APIClient = AppDependencies.shared.apiClient) {
        self.api = api
    }
    
    // MARK: - PlansRepository Protocol
    
    func fetchCountries(geography: Geography?, search: String?) async throws -> [CountryRow] {
        // 1. Build query parameters
        var query: [String: String] = [:]
        if let geography = geography {
            query["geography"] = geography.rawValue
        }
        
        let req = APIRequest(
            method: .GET,
            path: Path.countries,
            query: query.isEmpty ? nil : query
        )
        
        // 2. API returns { "data": [CountryRow] }
        let response: CountriesResponseDTO = try await api.send(req)
        var countries = response.data
        
        // 3. Client-side search filtering 
        if let search = search, !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let searchTerm = search.lowercased()
            countries = countries.filter { country in
                country.country_name.lowercased().contains(searchTerm) ||
                country.country_code.lowercased().contains(searchTerm) ||
                (country.covered_countries?.contains { $0.lowercased().contains(searchTerm) } ?? false)
            }
        }
        
        return countries
    }
    
    func fetchPackages(countryName: String) async throws -> [PackageRow] {
        // Direct API call - API acepta country_name según documentación oficial
            let req = APIRequest(
                method: .GET,
                path: Path.packages,
                query: ["country": countryName]  
            )
            
            let response: PackagesResponseDTO = try await api.send(req)
            return response.data
        }
    
    // MARK: - Response DTOs
    
    private struct CountriesResponseDTO: Decodable {
        let data: [CountryRow]
    }
    
    private struct PackagesResponseDTO: Decodable {
        let data: [PackageRow]
    }
}
