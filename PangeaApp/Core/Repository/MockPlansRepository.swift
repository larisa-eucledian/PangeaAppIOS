//
//  MockPlansRepository.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 11/08/25.
//


import Foundation

enum PlansError: Error, Equatable {
    case network, unauthorized, tenantInvalid, noData
    case badStatus(Int), decoding
}

final class MockPlansRepository: PlansRepository {

    // MARK: - Countries

    func fetchCountries(geography: Geography?, search: String?) async throws -> [CountryRow] {
        // Carga base
        var base: [CountryRow] = try load("countries_mock.json")
        if let g = geography {
            var tmp: [CountryRow] = []
            for row in base {
                if row.geography == g { tmp.append(row) }
            }
            base = tmp
        }

        let rawQ = (search ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if rawQ.isEmpty { return base }

        if geography == .local {
            var out: [CountryRow] = []
            for row in base {
                if row.country_name.localizedCaseInsensitiveContains(rawQ) ||
                   row.country_code.localizedCaseInsensitiveContains(rawQ) {
                    out.append(row)
                }
            }
            return out
        }

        // 4) MULTI (geography == nil): regiones/global que:
        //    - coincidan por nombre/código, O
        //    - incluyan al país buscado en covered_countries
        let all: [CountryRow] = try load("countries_mock.json")
        var locals: [CountryRow] = []
        for row in all {
            if row.geography == .local { locals.append(row) }
        }
        var matchedLocalCodes = Set<String>()
        for row in locals {
            if row.country_name.localizedCaseInsensitiveContains(rawQ) ||
               row.country_code.localizedCaseInsensitiveContains(rawQ) {
                matchedLocalCodes.insert(row.country_code)
            }
        }

        var candidates: [CountryRow] = []
        for row in base {
            if row.geography != .local { candidates.append(row) }
        }

        var result: [CountryRow] = []
        for row in candidates {
            if row.country_name.localizedCaseInsensitiveContains(rawQ) ||
               row.country_code.localizedCaseInsensitiveContains(rawQ) {
                result.append(row)
                continue
            }
            if let covered = row.covered_countries, !matchedLocalCodes.isEmpty {
                let hasMatch = covered.contains { matchedLocalCodes.contains($0) }
                if hasMatch { result.append(row) }
            }
        }

        return result
    }

    // MARK: - Packages

    func fetchPackages(countryName: String) async throws -> [PackageRow] {
        let countries: [CountryRow] = try load("countries_mock.json")
        var selected: CountryRow?
        for row in countries {
            if row.country_name.caseInsensitiveCompare(countryName) == .orderedSame {
                selected = row
                break
            }
        }
        guard let selected else { throw PlansError.noData }
        let code = selected.country_code

        // 2) abrir diccionario de packages por code
        let dict: [String: [PackageRow]] = try load("packages_mock.json")

        // 3) regresar lista (vacía si aún no hay key)
        return dict[code] ?? []
    }

    func fetchPackage(packageId: String) async throws -> PackageRow? {
        // Load all packages and find the one with matching package_id
        let dict: [String: [PackageRow]] = try load("packages_mock.json")
        for (_, packages) in dict {
            if let package = packages.first(where: { $0.package_id == packageId }) {
                return package
            }
        }
        return nil
    }

    // MARK: - Loader

    private func load<T: Decodable>(_ name: String) throws -> T {
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
            throw PlansError.noData
        }
        let data = try Data(contentsOf: url)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch let DecodingError.dataCorrupted(ctx) {
            print("DecodingError.dataCorrupted:", ctx.debugDescription, "path:", ctx.codingPath)
            throw PlansError.decoding
        } catch let DecodingError.keyNotFound(key, ctx) {
            print("Key not found:", key.stringValue, "in", name, "path:", ctx.codingPath)
            throw PlansError.decoding
        } catch let DecodingError.typeMismatch(type, ctx) {
            print("Type mismatch:", type, "in", name, "path:", ctx.codingPath)
            throw PlansError.decoding
        } catch let DecodingError.valueNotFound(type, ctx) {
            print("Value not found:", type, "in", name, "path:", ctx.codingPath)
            throw PlansError.decoding
        } catch {
            print("Unknown decode error in", name, ":", error)
            throw PlansError.decoding
        }
    }
}
