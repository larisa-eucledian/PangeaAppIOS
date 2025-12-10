//
//  CachedPlansRepository.swift
//  PangeaApp
//
//  Created: 23/11/25
//  Plans repository with cache-then-network strategy
//

import Foundation
import CoreData

extension Notification.Name {
    static let countriesDataUpdated = Notification.Name("countriesDataUpdated")
    static let packagesDataUpdated = Notification.Name("packagesDataUpdated")
}

final class CachedPlansRepository: PlansRepository {

    private let api: APIClient
    private let cacheManager = CacheManager.shared
    private let cacheValidityHours = 24

    // In-memory cache for packages (keyed by country name)
    private var packagesCache: [String: (packages: [PackageRow], timestamp: Date)] = [:]
    private let packagesCacheValidityMinutes = 30 // 30 minutes for packages
    private let cacheQueue = DispatchQueue(label: "com.pangea.packagescache", attributes: .concurrent)

    // Serial queue for Core Data write operations to prevent race conditions
    private let coreDataWriteQueue = DispatchQueue(label: "com.pangea.coredata.write")

    init(api: APIClient) {
        self.api = api
    }
    
    // MARK: - Fetch Countries (Cache-then-Network)

    func fetchCountries(geography: Geography?, search: String?) async throws -> [CountryRow] {
        // 1. Get cached data immediately (with client-side filtering)
        let cached = fetchCountriesFromCache(geography: geography, search: search)

        // 2. Start network fetch in background (always fetch ALL countries)
        Task.detached { [weak self] in
            do {
                // Always fetch all countries (no geography filter to API)
                let allFresh = try await self?.fetchCountriesFromNetwork(geography: nil, search: nil)
                guard let allFresh = allFresh, let self = self else { return }

                print("✅ Fetched \(allFresh.count) countries from network (background)")

                // Apply client-side filtering for the notification
                var filteredFresh = allFresh
                if let geo = geography {
                    filteredFresh = allFresh.filter { $0.geography == geo }
                }
                if let searchTerm = search?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !searchTerm.isEmpty {
                    filteredFresh = filteredFresh.filter { country in
                        country.country_name.lowercased().contains(searchTerm) ||
                        country.country_code.lowercased().contains(searchTerm) ||
                        (country.covered_countries?.contains { $0.lowercased().contains(searchTerm) } ?? false)
                    }
                }

                // Notify observers with filtered data
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: .countriesDataUpdated,
                        object: filteredFresh
                    )
                }
            } catch {
                print("⚠️ Background network fetch failed: \(error)")
            }
        }

        // 3. Return cached data if available
        if !cached.isEmpty {
            print("📦 Returning \(cached.count) countries from cache (instant)")
            return cached
        }

        // 4. No cache - wait for network (first time only)
        print("🔄 No cache, waiting for network...")
        let allCountries = try await fetchCountriesFromNetwork(geography: nil, search: nil)

        // Apply client-side filtering
        var filtered = allCountries
        if let geo = geography {
            filtered = allCountries.filter { $0.geography == geo }
        }
        if let searchTerm = search?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !searchTerm.isEmpty {
            filtered = filtered.filter { country in
                country.country_name.lowercased().contains(searchTerm) ||
                country.country_code.lowercased().contains(searchTerm) ||
                (country.covered_countries?.contains { $0.lowercased().contains(searchTerm) } ?? false)
            }
        }

        return filtered
    }
    
    // MARK: - Fetch Packages (Cache-then-Network)

    func fetchPackages(countryName: String) async throws -> [PackageRow] {
        // 1. Get cached data immediately (thread-safe read)
        let cached = cacheQueue.sync { () -> [PackageRow]? in
            guard let entry = packagesCache[countryName] else { return nil }

            // Check if cache is still valid (30 minutes)
            let age = Date().timeIntervalSince(entry.timestamp)
            let validitySeconds = Double(packagesCacheValidityMinutes * 60)

            if age < validitySeconds {
                return entry.packages
            } else {
                return nil // Cache expired
            }
        }

        // 2. Start network fetch in background (always)
        Task.detached { [weak self] in
            do {
                let fresh = try await self?.fetchPackagesFromNetwork(countryName: countryName)
                guard let fresh = fresh, let self = self else { return }

                print("✅ Fetched \(fresh.count) packages for \(countryName) from network (background)")

                // Save to in-memory cache (thread-safe write)
                self.cacheQueue.async(flags: .barrier) {
                    self.packagesCache[countryName] = (packages: fresh, timestamp: Date())
                }

                // Notify observers that data updated
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: .packagesDataUpdated,
                        object: (countryName: countryName, packages: fresh)
                    )
                }
            } catch {
                print("⚠️ Background network fetch for packages failed: \(error)")
            }
        }

        // 3. Return cached data if available
        if let cachedPackages = cached, !cachedPackages.isEmpty {
            print("📦 Returning \(cachedPackages.count) packages for \(countryName) from cache (instant)")
            return cachedPackages
        }

        // 4. No cache - wait for network (first time only)
        print("🔄 No cache for \(countryName), waiting for network...")
        return try await fetchPackagesFromNetwork(countryName: countryName)
    }

    func fetchPackage(packageId: String) async throws -> PackageRow? {
        let request = APIRequest(
            method: .GET,
            path: "tenant/packages",
            query: ["package_id": packageId],
            headers: nil,
            jsonBody: nil
        )

        let response: PackagesResponseDTO = try await api.send(request)
        return response.data.first
    }

    // MARK: - Cache Management

    func clearCache() {
        // Clear Core Data countries cache (using serial queue to prevent race conditions)
        coreDataWriteQueue.async { [weak self] in
            guard let self = self else { return }
            let context = self.cacheManager.context

            context.performAndWait {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CachedCountry.fetchRequest()
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                try? context.execute(deleteRequest)
                self.cacheManager.save()
                print("🗑️ Cleared countries cache")
            }
        }

        // Clear in-memory packages cache
        cacheQueue.async(flags: .barrier) {
            self.packagesCache.removeAll()
            print("🗑️ Cleared packages cache")
        }
    }

    // MARK: - Private: Cache Operations
    
    private func fetchCountriesFromCache(geography: Geography?, search: String?) -> [CountryRow] {
        let context = cacheManager.context

        var result: [CountryRow] = []

        context.performAndWait {
            let fetchRequest: NSFetchRequest<CachedCountry> = CachedCountry.fetchRequest()

            var predicates: [NSPredicate] = []

            // Check cache validity (24h)
            let validDate = Date().addingTimeInterval(-Double(cacheValidityHours * 3600))
            predicates.append(NSPredicate(format: "lastUpdated >= %@", validDate as NSDate))

            // Geography filter (Core Data level)
            if let geo = geography {
                predicates.append(NSPredicate(format: "geography == %@", geo.rawValue))
            }

            // Search filter
            if let searchText = search?.lowercased(), !searchText.isEmpty {
                predicates.append(NSPredicate(format: "countryName CONTAINS[cd] %@", searchText))
            }

            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "countryName", ascending: true)]

            do {
                let cached = try context.fetch(fetchRequest)
                print("Cache fetch: found \(cached.count) raw entities (geography filter: \(geography?.rawValue ?? "NONE"))")
                result = cached.compactMap { $0.toCountryRow() }
                print("Cache fetch: converted to \(result.count) CountryRows")
            } catch {
                print("Cache fetch error: \(error)")
            }
        }

        return result
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
    
    private func fetchPackagesFromNetwork(countryName: String) async throws -> [PackageRow] {
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
        // Use serial queue to prevent race conditions when saving to Core Data
        coreDataWriteQueue.async { [weak self] in
            guard let self = self else { return }
            let context = self.cacheManager.context

            context.performAndWait {
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
