//
//  PlansRepository.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 11/08/25.
//

protocol PlansRepository {
    func fetchCountries(geography: Geography?, search: String?) async throws -> [CountryRow]
    func fetchPackages(countryName: String) async throws -> [PackageRow]
    func fetchPackage(packageId: String) async throws -> PackageRow?
}


