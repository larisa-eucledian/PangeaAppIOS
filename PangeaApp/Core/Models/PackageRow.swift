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
    let dataAmount: String        // "1024" (MB) o "10240", etc.
    let dataUnit: String          // "MB" o "GB"
    let callType: String?         // "all" | ...
    let callAmount: String?
    let callUnit: String?
    let smsType: String?
    let smsAmount: String?
    let smsUnit: String?
    let withSMS: Bool?
    let withCall: Bool?
    let withHotspot: Bool?
    let withDataRoaming: Bool?
    let withUsageCheck: Bool?
    let currency: String?
    let geography: Geography
    let coverage: [String]?
    let country_name: String
}
