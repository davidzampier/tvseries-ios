//
//  AuthorizationViewModel.swift
//  TVSeries Guide
//
//  Created by David Zampier on 06/02/22.
//

import Foundation

protocol AuthorizationViewModelProtocol {
    var status: AuthorizationStatus { get }
    var authorizationType: AuthorizationType? { get }
    var availableBiometricType: BiometricType? { get }
    func didConfirm(pin: String)
    func didTapUseBiometryButton()
    func didTapDisableBiometryButton()
}

protocol AuthorizationViewModelDelegate: AnyObject {
    func didChangeStatus(_ status: AuthorizationStatus)
}

final class AuthorizationViewModel {
    
    private let authorizationManager: AuthorizationManagerProtocol
    
    weak var delegate: AuthorizationViewModelDelegate?
    
    init(authorizationManager: AuthorizationManagerProtocol = AuthorizationManager.shared) {
        self.authorizationManager = authorizationManager
    }
    
    private func setPin(_ pin: String) {
        do {
            try self.authorizationManager.setPassword(pin)
            self.delegate?.didChangeStatus(self.status)
        } catch { }
    }
    
    private func authorize(_ pin: String) {
        if self.authorizationManager.validatePassword(pin) {
            self.delegate?.didChangeStatus(.authorized)
        }
    }
}


// MARK: - AuthorizationViewModelProtocol

extension AuthorizationViewModel: AuthorizationViewModelProtocol {
    
    var status: AuthorizationStatus {
        self.authorizationManager.status
    }
    
    var authorizationType: AuthorizationType? {
        self.authorizationManager.authorizationType
    }
    
    var availableBiometricType: BiometricType? {
        self.authorizationManager.availableBiometricType
    }
    
    func didConfirm(pin: String) {
        guard pin.count >= self.authorizationManager.mininumPasswordLength else {
            return
        }
        switch self.authorizationType {
        case .password:
            switch self.status {
            case .unauthorized:
                self.authorize(pin)
            case .authorized:
                self.authorizationManager.disablePassword(pin)
            }
        case .biometry:
            break
        case .none:
            self.setPin(pin)
        }
    }
    
    func didTapUseBiometryButton() {
        self.authorizationManager.authenticateWithBiometrics { [weak self] success in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.delegate?.didChangeStatus(self.status)
            }
        }
    }
    
    func didTapDisableBiometryButton() {
        self.authorizationManager.disableBiometrics()
        self.delegate?.didChangeStatus(.authorized)
    }
}
