//
//  PackageRow.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 11/08/25.
//

import Foundation

struct PackageRow: Codable, Hashable {
    let id: Int
    let documentId: String
    let package_id: String
    let package: String
    let validity_days: Int
    let price_public: Double
    let dataAmount: String
    let dataUnit: String
    let currency: String?
    let geography: Geography
    let coverage: [String]?
    let country_name: String
}
