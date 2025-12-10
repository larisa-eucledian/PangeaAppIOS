//
//  CachedESimsRepository.swift
//  PangeaApp
//
//  Created: 23/11/25
//  eSIMs repository with cache-then-network strategy
//

import Foundation
import CoreData

extension Notification.Name {
    static let esimsDataUpdated = Notification.Name("esimsDataUpdated")
}

final class CachedESimsRepository: ESimsRepository {
    
    private let api: APIClient
    private let cacheManager = CacheManager.shared
    private let cacheValidityMinutes = 60 // 1 hour validity
    
    init(api: APIClient) {
        self.api = api
    }
    
    // MARK: - Fetch eSIMs (Cache-then-Network)

    func fetchESims() async throws -> [ESimRow] {
        // 1. Get cached data immediately
        let cached = fetchESimsFromCache()

        // 2. Start network fetch in background (always)
        Task.detached { [weak self] in
            do {
                let fresh = try await self?.fetchESimsFromNetwork()
                guard let fresh = fresh, let self = self else { return }

                print("✅ Fetched \(fresh.count) eSIMs from network (background)")

                // Save to cache
                await MainActor.run {
                    self.saveESimsToCache(fresh)

                    // Notify observers that data updated
                    NotificationCenter.default.post(
                        name: .esimsDataUpdated,
                        object: fresh
                    )
                }
            } catch {
                print("⚠️ Background network fetch failed: \(error)")
            }
        }

        // 3. Return cached data if available
        if !cached.isEmpty {
            print("📦 Returning \(cached.count) eSIMs from cache (instant)")
            return cached
        }

        // 4. No cache - wait for network (first time only)
        print("🔄 No cache, waiting for network...")
        return try await fetchESimsFromNetwork()
    }
    
    // MARK: - Activate eSIM
    
    func activate(esimId: String) async throws -> ESimRow {
        let requestBody = ActivateESimRequestDTO(esim_id: esimId)
        
        let request = APIRequest(
            method: .POST,
            path: "esim/activate",
            query: nil,
            headers: nil,
            jsonBody: requestBody
        )
        
        let response: ActivateESimResponseDTO = try await api.send(request)
        let activated = response.esim.toDomain()
        
        // Update cache
        Task.detached { [weak self] in
            self?.updateESimInCache(activated)
        }
        
        return activated
    }
    
    // MARK: - Fetch Usage

    func fetchUsage(esimId: String) async throws -> ESimUsage {
        let request = APIRequest(
            method: .GET,
            path: "esim/usage/\(esimId)",
            query: nil,
            headers: nil,
            jsonBody: nil
        )

        let response: ESimUsageResponseDTO = try await api.send(request)
        return response.toDomain()
    }

    // MARK: - Cache Management

    func clearCache() {
        let context = cacheManager.context

        context.perform {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CachedESim.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try? context.execute(deleteRequest)
            self.cacheManager.save()
            print("🗑️ Cleared eSIMs cache")
        }
    }
    
    // MARK: - Private: Network Operations
    
    private func fetchESimsFromNetwork() async throws -> [ESimRow] {
        let request = APIRequest(
            method: .GET,
            path: "esims",
            query: nil,
            headers: nil,
            jsonBody: nil
        )
        
        let response: ESimsResponseDTO = try await api.send(request)
        return response.data.map { $0.toDomain() }
    }
    
    // MARK: - Private: Cache Operations
    
    private func fetchESimsFromCache() -> [ESimRow] {
        let context = cacheManager.context

        var result: [ESimRow] = []

        context.performAndWait {
            let fetchRequest: NSFetchRequest<CachedESim> = CachedESim.fetchRequest()

            // Check cache validity (1 hour)
            let validDate = Date().addingTimeInterval(-Double(cacheValidityMinutes * 60))
            fetchRequest.predicate = NSPredicate(format: "lastUpdated >= %@", validDate as NSDate)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

            do {
                let cached = try context.fetch(fetchRequest)
                result = cached.compactMap { $0.toESimRow() }
            } catch {
                print("Cache fetch error: \(error)")
            }
        }

        return result
    }
    
    private func saveESimsToCache(_ esims: [ESimRow]) {
        let context = cacheManager.context
        
        context.perform {
            // Clear old cache
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CachedESim.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try? context.execute(deleteRequest)
            
            // Save new data
            let now = Date()
            for esim in esims {
                let cached = CachedESim(context: context)
                cached.esimId = esim.esimId
                cached.iccid = esim.iccid
                cached.status = esim.status.rawValue
                cached.packageName = esim.packageName
                cached.qrCodeURL = esim.qrCodeUrl
                cached.iosQuickInstall = esim.iosQuickInstall
                cached.activationDate = esim.activationDate
                cached.expirationDate = esim.expirationDate
                cached.createdAt = esim.createdAt
                cached.lastUpdated = now
                
                // Store coverage as JSON
                if let jsonData = try? JSONEncoder().encode(esim.coverage) {
                    cached.coverage = jsonData.base64EncodedString()
                }
            }
            
            self.cacheManager.save()
            print("Saved \(esims.count) eSIMs to cache")
        }
    }
    
    private func updateESimInCache(_ esim: ESimRow) {
        let context = cacheManager.context
        
        context.perform {
            let fetchRequest: NSFetchRequest<CachedESim> = CachedESim.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "esimId == %@", esim.esimId)
            
            do {
                let results = try context.fetch(fetchRequest)
                let cached = results.first ?? CachedESim(context: context)
                
                cached.esimId = esim.esimId
                cached.iccid = esim.iccid
                cached.status = esim.status.rawValue
                cached.packageName = esim.packageName
                cached.qrCodeURL = esim.qrCodeUrl
                cached.iosQuickInstall = esim.iosQuickInstall
                cached.activationDate = esim.activationDate
                cached.expirationDate = esim.expirationDate
                cached.createdAt = esim.createdAt
                cached.lastUpdated = Date()
                
                if let jsonData = try? JSONEncoder().encode(esim.coverage) {
                    cached.coverage = jsonData.base64EncodedString()
                }
                
                self.cacheManager.save()
                print("Updated eSIM in cache: \(esim.esimId)")
            } catch {
                print("Failed to update cache: \(error)")
            }
        }
    }
}

// MARK: - CachedESim Extension

extension CachedESim {
    func toESimRow() -> ESimRow? {
        guard let id = esimId,
              let name = packageName,
              let statusString = status else {
            return nil
        }
        
        let statusEnum = ESimStatus(rawValue: statusString) ?? .unknown
        
        // Decode coverage
        var coverageArray: [String] = []
        if let coverageString = coverage,
           let data = Data(base64Encoded: coverageString) {
            coverageArray = (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        
        return ESimRow(
            id: 0, // Not cached
            documentId: id, // Use esimId as documentId
            esimId: id,
            iccid: iccid,
            status: statusEnum,
            activationDate: activationDate,
            expirationDate: expirationDate,
            packageName: name,
            packageId: "", // Not cached
            number: nil, // Not cached
            coverage: coverageArray,
            userEmail: "", // Not cached
            paymentIntentId: "", // Not cached
            qrCodeUrl: qrCodeURL,
            lpaCode: nil, // Not cached
            smdpAddress: nil, // Not cached
            activationCode: nil, // Not cached
            iosQuickInstall: iosQuickInstall,
            createdAt: createdAt,
            updatedAt: nil,
            publishedAt: nil
        )
    }
}
