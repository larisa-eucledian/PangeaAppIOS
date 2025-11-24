//
//  TransactionRepository.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 23/11/25.
//

protocol TransactionRepository {
    func createStripeTransaction(
        amount: Double,
        currency: String,
        packageId: String
    ) async throws -> TransactionResponse
}

struct TransactionResponse: Decodable {
    let clientSecret: String
    let paymentIntentId: String
    let payment_method: String
}
