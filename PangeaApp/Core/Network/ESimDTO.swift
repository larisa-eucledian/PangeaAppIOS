//
//  ESimDTO.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 22/11/25.
//

import Foundation

/// DTO for GET /api/esims response
struct ESimsResponseDTO: Decodable {
    let data: [ESimDTO]
    let meta: MetaDTO?
    
    struct MetaDTO: Decodable {
        let pagination: PaginationDTO?
        
        struct PaginationDTO: Decodable {
            let total: Int
        }
    }
}

/// DTO for individual eSIM from API
struct ESimDTO: Decodable {
    let id: Int
    let documentId: String
    let esim_id: String
    let iccid: String?
    let esim_status: String
    let activation_date: String?
    let expiration_date: String?
    let package_name: String
    let package_id: String
    let number: String?
    let coverage: [String]
    let user_email: String
    let payment_intent_id: String
    let qr_code_url: String?
    let lpa_code: String?
    let smdp_address: String?
    let activation_code: String?
    let ios_quick_install: String?
    let createdAt: String?
    let updatedAt: String?
    let publishedAt: String?
    let locale: String?
    
    // Convert DTO to domain model
    func toDomain() -> ESimRow {
        let dateFormatter = ISO8601DateFormatter()
        
        return ESimRow(
            id: id,
            documentId: documentId,
            esimId: esim_id,
            iccid: iccid,
            status: ESimStatus(rawValue: esim_status) ?? .unknown,
            activationDate: activation_date.flatMap { dateFormatter.date(from: $0) },
            expirationDate: expiration_date.flatMap { dateFormatter.date(from: $0) },
            packageName: package_name,
            packageId: package_id,
            number: number,
            coverage: coverage,
            userEmail: user_email,
            paymentIntentId: payment_intent_id,
            qrCodeUrl: qr_code_url,
            lpaCode: lpa_code,
            smdpAddress: smdp_address,
            activationCode: activation_code,
            iosQuickInstall: ios_quick_install,
            createdAt: createdAt.flatMap { dateFormatter.date(from: $0) },
            updatedAt: updatedAt.flatMap { dateFormatter.date(from: $0) },
            publishedAt: publishedAt.flatMap { dateFormatter.date(from: $0) }
        )
    }
}

/// DTO for POST /api/esim/activate request
struct ActivateESimRequestDTO: Encodable {
    let esim_id: String
}

/// DTO for POST /api/esim/activate response
struct ActivateESimResponseDTO: Decodable {
    let success: Bool
    let esim: ESimDTO
}

/// DTO for GET /api/esim/usage/{esim_id} response
struct ESimUsageResponseDTO: Decodable {
    let esim_id: String
    let iccid: String
    let package_name: String
    let usage: UsageDataDTO
    
    struct UsageDataDTO: Decodable {
        let status: String
        let data: UsageDetailsDTO
    }
    
    struct UsageDetailsDTO: Decodable {
        let iccid: String
        let status: String
        let startedAt: Int
        let expiredAt: Int
        let allowedData: Int
        let remainingData: Int
        let allowedSms: Int
        let remainingSms: Int
        let allowedVoice: Int
        let remainingVoice: Int
    }
    
    // Convert to domain model
    func toDomain() -> ESimUsage {
        ESimUsage(
            esimId: esim_id,
            iccid: iccid,
            packageName: package_name,
            usage: ESimUsage.UsageData(
                status: usage.status,
                data: ESimUsage.UsageDetails(
                    iccid: usage.data.iccid,
                    status: usage.data.status,
                    startedAt: usage.data.startedAt,
                    expiredAt: usage.data.expiredAt,
                    allowedData: usage.data.allowedData,
                    remainingData: usage.data.remainingData,
                    allowedSms: usage.data.allowedSms,
                    remainingSms: usage.data.remainingSms,
                    allowedVoice: usage.data.allowedVoice,
                    remainingVoice: usage.data.remainingVoice
                )
            )
        )
    }
}
