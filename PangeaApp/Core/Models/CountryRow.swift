//
//  CountryRow.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 11/08/25.
//

import Foundation

enum Geography: String, Codable { case local, regional, global }

struct CountryRow: Codable, Hashable {
    let id: Int
    let documentId: String
    let country_code: String
    let country_name: String
    let createdAt: String?
    let updatedAt: String?
    let publishedAt: String?
    let locale: String?
    let region: String?
    let image_url: String?
    let languages: [String:String]?
    let currencies: [String: CurrencyInfo]?
    let callingCodes: [String]?
    let geography: Geography
    let covered_countries: [String]?
    let packageCount: Int?
    
    struct CurrencyInfo: Codable, Hashable {
        let name: String
        let symbol: String?
    }
}
