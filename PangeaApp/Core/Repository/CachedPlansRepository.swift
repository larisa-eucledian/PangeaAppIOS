//
//  CachedPlansRepository.swift
//  PangeaApp
//
//  Created: 23/11/25
//  Plans repository with cache-first strategy
//

import Foundation
import CoreData

final class CachedPlansRepository: PlansRepository {
    
    private let api: APIClient
    private let cacheManager = CacheManager.shared
    private let cacheValidityHours = 24
    
    init(api: APIClient) {
        self.api = api
    }
    
    // MARK: - Fetch Countries (Cache-First)
    
    func fetchCountries(geography: Geography?, search: String?) async throws -> [CountryRow] {
        // 1. Try cache first
        let cached = fetchCountriesFromCache(geography: geography, search: search)
        
        if !cached.isEmpty {
            print("Loaded \(cached.count) countries from cache (geography: \(geography?.rawValue ?? "nil"))")
            
            // Refresh in background ONLY if online
            Task.detached { [weak self] in
                try? await self?.refreshCountriesIfNeeded()
            }
            
            return cached
        }
        
        // 2. No cache for this geography - fetch from network
        print("Fetching countries from network (geography: \(geography?.rawValue ?? "nil"))...")
        return try await fetchCountriesFromNetwork(geography: geography, search: search)
    }
    
    // MARK: - Fetch Packages (Network-only)
    
    func fetchPackages(countryName: String) async throws -> [PackageRow] {
        let request = APIRequest(
            method: .GET,
            path: "tenant/packages",
            query: ["country": countryName],
            headers: nil,
            jsonBody: nil
        )
        
        let response: PackagesResponseDTO = try await api.send(request)
        return response.data
    }
    
    // MARK: - Private: Cache Operations
    
    private func fetchCountriesFromCache(geography: Geography?, search: String?) -> [CountryRow] {
        let context = cacheManager.context
        let fetchRequest: NSFetchRequest<CachedCountry> = CachedCountry.fetchRequest()
        
        var predicates: [NSPredicate] = []
        
        // Check cache validity (24h)
        let validDate = Date().addingTimeInterval(-Double(cacheValidityHours * 3600))
        predicates.append(NSPredicate(format: "lastUpdated >= %@", validDate as NSDate))
        
        // Search filter
        if let searchText = search?.lowercased(), !searchText.isEmpty {
            predicates.append(NSPredicate(format: "countryName CONTAINS[cd] %@", searchText))
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "countryName", ascending: true)]
        
        do {
            let cached = try context.fetch(fetchRequest)
            print("Cache fetch: found \(cached.count) raw entities (geography filter: \(geography?.rawValue ?? "NONE"))")
            let converted = cached.compactMap { $0.toCountryRow() }
            print("Cache fetch: converted to \(converted.count) CountryRows")
            return converted
        } catch {
            print("Cache fetch error: \(error)")
            return []
        }
    }
    
    private func fetchCountriesFromNetwork(geography: Geography?, search: String?) async throws -> [CountryRow] {
        var query: [String: String] = [:]
        
        if let geo = geography {
            query["geography"] = geo.rawValue
        }
        
        let request = APIRequest(
            method: .GET,
            path: "countries",
            query: query.isEmpty ? nil : query,
            headers: nil,
            jsonBody: nil
        )
        
        let response: CountriesResponseDTO = try await api.send(request)
        var countries = response.data
        
        // Client-side search filtering (same as RealPlansRepository)
        if let searchTerm = search?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !searchTerm.isEmpty {
            countries = countries.filter { country in
                country.country_name.lowercased().contains(searchTerm) ||
                country.country_code.lowercased().contains(searchTerm) ||
                (country.covered_countries?.contains { $0.lowercased().contains(searchTerm) } ?? false)
            }
        }
        
        // Save to cache in background
        Task.detached { [weak self] in
            self?.saveCountriesToCache(response.data) // Save all, not filtered
        }
        
        return countries
    }
    
    private func refreshCountriesIfNeeded() async throws {
        // Check if cache needs refresh
        let context = cacheManager.context
        let fetchRequest: NSFetchRequest<CachedCountry> = CachedCountry.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastUpdated", ascending: false)]
        
        do {
            let results = try context.fetch(fetchRequest)
            if let latest = results.first, let lastUpdate = latest.lastUpdated {
                let age = Date().timeIntervalSince(lastUpdate)
                if age < 3600 { // Less than 1 hour old
                    return // Skip refresh
                }
            }
        } catch {
            // Ignore error, will try to refresh anyway
        }
        
        print(" Refreshing countries cache...")
        _ = try await fetchCountriesFromNetwork(geography: nil, search: nil)
    }
    
    private func saveCountriesToCache(_ countries: [CountryRow]) {
        let context = cacheManager.context
        
        context.perform {
            // Clear old cache
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CachedCountry.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try? context.execute(deleteRequest)
            
            // Save new data
            let now = Date()
            for country in countries {
                let cached = CachedCountry(context: context)
                // No need for countryId - use countryCode as identifier
                cached.countryName = country.country_name
                cached.countryCode = country.country_code
                cached.imageURL = country.image_url
                cached.geography = country.geography.rawValue
                cached.packageCount = Int16(country.packageCount ?? 0)
                cached.lastUpdated = now
                
                // Store covered countries as JSON
                if let covered = country.covered_countries,
                   let jsonData = try? JSONEncoder().encode(covered) {
                    cached.coveredCountries = jsonData.base64EncodedString()
                }
            }
            
            self.cacheManager.save()
            print("✅ Saved \(countries.count) countries to cache")
        }
    }
    
    // MARK: - Response DTOs
    
    private struct CountriesResponseDTO: Decodable {
        let data: [CountryRow]
    }
    
    private struct PackagesResponseDTO: Decodable {
        let data: [PackageRow]
    }
}

// MARK: - CachedCountry Extension

extension CachedCountry {
    func toCountryRow() -> CountryRow? {
        guard let name = countryName,
              let code = countryCode,
              let geo = geography else {
            return nil
        }
        
        let geographyEnum = Geography(rawValue: geo) ?? .local
        
        // Decode covered countries
        var covered: [String]? = nil
        if let coveredString = coveredCountries,
           let data = Data(base64Encoded: coveredString) {
            covered = try? JSONDecoder().decode([String].self, from: data)
        }
        
        return CountryRow(
            id: 0, // Not cached
            documentId: code, // Use country code as ID
            country_code: code,
            country_name: name,
            createdAt: nil,
            updatedAt: nil,
            publishedAt: nil,
            locale: nil,
            region: nil,
            image_url: imageURL,
            languages: nil,
            currencies: nil,
            callingCodes: nil,
            geography: geographyEnum,
            covered_countries: covered,
            packageCount: Int(packageCount)
        )
    }
}
