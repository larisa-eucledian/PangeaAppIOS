//
//  RealTransactionRepository.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 23/11/25.
//

import Foundation

final class RealTransactionRepository: TransactionRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func createStripeTransaction(
        amount: Double,
        currency: String,
        packageId: String
    ) async throws -> TransactionResponse {

        struct RequestBody: Encodable {
            let amount: Double
            let currency: String
            let package_id: String
            let payment_method: String
        }

        let body = RequestBody(
            amount: amount,
            currency: currency,
            package_id: packageId,
            payment_method: "stripe"
        )

        let req = APIRequest(
            method: .POST,
            path: "transactions",
            jsonBody: body   
        )

        return try await apiClient.send(req)
    }
}
