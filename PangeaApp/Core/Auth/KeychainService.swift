//
//  KeychainService.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 26/09/25.
//

import Foundation
import Security

enum KeychainService {
    private static let service = "com.pangeaapp.auth"
    private static func query(_ account: String) -> [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: service,
         kSecAttrAccount as String: account]
    }

    static func save(_ data: Data, account: String) throws {
        let q = query(account)
        SecItemDelete(q as CFDictionary)
        var attrs = q
        attrs[kSecValueData as String] = data
        let status = SecItemAdd(attrs as CFDictionary, nil)
        guard status == errSecSuccess else { throw AuthError.server }
    }

    static func read(account: String) throws -> Data? {
        var q = query(account)
        q[kSecReturnData as String] = true
        q[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        let status = SecItemCopyMatching(q as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess else { throw AuthError.server }
        return (item as? Data)
    }

    static func delete(account: String) {
        SecItemDelete(query(account) as CFDictionary)
    }
}
