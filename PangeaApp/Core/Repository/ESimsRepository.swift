//
//  ESimsRepository.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 22/11/25.
//

import Foundation

protocol ESimsRepository {
    /// Fetch all eSIMs for the authenticated user
    /// GET /api/esims
    func fetchESims() async throws -> [ESimRow]
    
    /// Activate an eSIM
    /// POST /api/esim/activate
    func activate(esimId: String) async throws -> ESimRow
    
    /// Fetch usage data for a specific eSIM
    /// GET /api/esim/usage/{esim_id}
    func fetchUsage(esimId: String) async throws -> ESimUsage
}
