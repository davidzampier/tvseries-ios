//
//  AuthorizationManager.swift
//  TVSeries Guide
//
//  Created by David Zampier on 06/02/22.
//

import Foundation
import LocalAuthentication

protocol AuthorizationManagerProtocol {
    var status: AuthorizationStatus { get }
    var authorizationType: AuthorizationType? { get }
    var availableBiometricType: BiometricType? { get }
    var mininumPasswordLength: Int { get }
    func setPassword(_ password: String) throws
    func getPassword() throws -> String
    func validatePassword(_ password: String) -> Bool
    func authenticateWithBiometrics(completion: @escaping (Bool) -> Void)
    func disablePassword(_ password: String)
    func disableBiometrics()
}

final class AuthorizationManager: AuthorizationManagerProtocol {
    
    static let shared = AuthorizationManager()
    private let laContext = LAContext()
    
    enum KeychainError: Error {
        case unhandledError(status: OSStatus?)
        case itemNotFound
    }
    
    private enum Service: String {
        case password
        case authType
    }
    
    private(set) var mininumPasswordLength: Int = 4
    private(set) var status: AuthorizationStatus = .unauthorized
    
    var authorizationType: AuthorizationType? {
        guard let data = try? self.getData(for: .authType),
                let string = String(data: data, encoding: .utf8),
                let authType = AuthorizationType(rawValue: string) else {
            return nil
        }
        return authType
    }
    
    var availableBiometricType: BiometricType? {
        guard self.laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            return nil
        }
        switch self.laContext.biometryType {
        case .none: return nil
        case .faceID: return .faceID
        case .touchID: return .touchID
        @unknown default: return nil
        }
    }
    
    func setPassword(_ password: String) throws {
        guard password.count >= self.mininumPasswordLength,
              let passwordData = password.data(using: .utf8) else {
            return
        }
        try self.setData(passwordData, for: .password)
        self.setAuthorizationType(.password)
        self.status = .authorized
    }
    
    func getPassword() throws -> String {
        guard let data = try self.getData(for: .password), let password = String(data: data, encoding: .utf8) else {
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
    
    func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        guard self.availableBiometricType != nil else {
            completion(false)
            return
        }
        self.setAuthorizationType(.biometry)
        self.laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Protect the App") { [weak self] success, error in
            self?.status = success ? .authorized : .unauthorized
            completion(success)
        }
    }
    
    func disablePassword(_ password: String) {
        guard self.validatePassword(password) else {
            return
        }
        try? self.deleteItem(for: .password)
        try? self.deleteItem(for: .authType)
        self.status = .unauthorized
    }
    
    func disableBiometrics() {
        try? self.deleteItem(for: .authType)
        self.status = .unauthorized
    }
    
    
    // MARK: - Private Methods
    
    private func setAuthorizationType(_ type: AuthorizationType) {
        guard let data = type.rawValue.data(using: .utf8) else { return }
        try? self.setData(data, for: .authType)
    }
    
    private func setData(_ data: Data, for service: Service) throws {
        let query: [String: Any] = [
          kSecClass as String: kSecClassGenericPassword,
          kSecAttrService as String: service.rawValue,
          kSecValueData as String: data
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }
    
    private func getData(for service: Service) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service.rawValue,
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
        return existingItem?[kSecValueData as String] as? Data
    }
    
    private func deleteItem(for service: Service) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service.rawValue
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
}

enum AuthorizationStatus {
    case authorized
    case unauthorized
}

enum AuthorizationType: String {
    case biometry
    case password
}

enum BiometricType {
    case touchID
    case faceID
}
