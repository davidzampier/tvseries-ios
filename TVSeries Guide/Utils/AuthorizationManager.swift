//
//  AuthorizationManager.swift
//  TVSeries Guide
//
//  Created by David Zampier on 06/02/22.
//

import Foundation

protocol AuthorizationManagerProtocol {
    var status: AuthorizationStatus { get }
    var mininumPasswordLength: Int { get }
    func setPassword(_ password: String) throws
    func getPassword() throws -> String
    func validatePassword(_ password: String) -> Bool
}

final class AuthorizationManager: AuthorizationManagerProtocol {
    
    static let shared = AuthorizationManager()
    
    enum KeychainError: Error {
        case unhandledError(status: OSStatus?)
        case itemNotFound
    }
    
    private let service = "Login"
    private(set) var mininumPasswordLength: Int = 4
    private(set) var status: AuthorizationStatus
    
    private init() {
        self.status = .notSet
        if (try? self.getPassword()) != nil {
            self.status = .unauthorized
        }
    }
    
    func setPassword(_ password: String) throws {
        guard password.count >= self.mininumPasswordLength,
              let passwordData = password.data(using: .utf8) else {
            return
        }
        let query: [String: Any] = [
          kSecClass as String: kSecClassGenericPassword,
          kSecAttrService as String: self.service,
          kSecValueData as String: passwordData
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        self.status = .authorized
    }
    
    func getPassword() throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
        let existingItem = item as? [String: Any]
        guard let data = existingItem?[kSecValueData as String] as? Data, let password = String(data: data, encoding: .utf8) else {
            throw KeychainError.unhandledError(status: nil)
        }
        return password
    }
    
    func validatePassword(_ password: String) -> Bool {
        guard let storedPassord = try? self.getPassword() else {
            return false
        }
        let isAuthorized = password == storedPassord
        self.status = isAuthorized ? .authorized : .unauthorized
        return isAuthorized
    }
}

enum AuthorizationStatus {
    case notSet
    case authorized
    case unauthorized
}
