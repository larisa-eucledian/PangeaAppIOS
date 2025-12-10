//
//  ESimRow.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 22/11/25.
//

import Foundation

/// Domain model for eSIM
struct ESimRow: Identifiable, Codable, Hashable {
    let id: Int
    let documentId: String
    let esimId: String  // UUID
    let iccid: String?
    let status: ESimStatus
    let activationDate: Date?
    let expirationDate: Date?
    let packageName: String
    let packageId: String
    let number: String?
    let coverage: [String]  // Array of country codes
    let userEmail: String
    let paymentIntentId: String
    
    // QR Code / Activation info
    let qrCodeUrl: String?
    let lpaCode: String?
    let smdpAddress: String?
    let activationCode: String?
    let iosQuickInstall: String?
    
    // Timestamps
    let createdAt: Date?
    let updatedAt: Date?
    let publishedAt: Date?
    
    // Computed properties
    var isActive: Bool {
        status == .installed
    }
    
    var isExpired: Bool {
        guard let expDate = expirationDate else { return false }
        return expDate < Date()
    }
    
    var formattedExpirationDate: String? {
        guard let date = expirationDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

enum ESimStatus: String, Codable, CaseIterable {
    case readyForActivation = "READY FOR ACTIVATION"
    case installed = "INSTALLED"
    case expired = "EXPIRED"
    case unknown = "UNKNOWN"
    
    var displayName: String {
        switch self {
        case .readyForActivation: return NSLocalizedString("esim.status.ready", comment: "eSIM ready for activation")
        case .installed: return NSLocalizedString("esim.status.active", comment: "eSIM active")
        case .expired: return NSLocalizedString("esim.status.expired", comment: "eSIM expired")
        case .unknown: return NSLocalizedString("esim.status.unknown", comment: "eSIM status unknown")
        }
    }
    
    var badgeColorName: String {
        switch self {
        case .readyForActivation: return "systemYellow"
        case .installed: return "systemGreen"
        case .expired: return "systemRed"
        case .unknown: return "systemGray"
        }
    }
}

// MARK: - Usage Data
struct ESimUsage: Codable {
    let esimId: String
    let iccid: String
    let packageName: String
    let usage: UsageData
    
    struct UsageData: Codable {
        let status: String
        let data: UsageDetails
    }
    
    struct UsageDetails: Codable {
        let iccid: String
        let status: String
        let startedAt: Int  // Unix timestamp
        let expiredAt: Int  // Unix timestamp
        let allowedData: Int  // MB
        let remainingData: Int  // MB
        let allowedSms: Int
        let remainingSms: Int
        let allowedVoice: Int
        let remainingVoice: Int
        
        var dataUsedMB: Int {
            allowedData - remainingData
        }
        
        var dataUsagePercentage: Double {
            guard allowedData > 0 else { return 0 }
            return Double(dataUsedMB) / Double(allowedData) * 100
        }
    }
}
