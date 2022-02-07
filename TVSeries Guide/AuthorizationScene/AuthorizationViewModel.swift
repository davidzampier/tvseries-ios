//
//  AuthorizationViewModel.swift
//  TVSeries Guide
//
//  Created by David Zampier on 06/02/22.
//

import Foundation

protocol AuthorizationViewModelProtocol {
    var status: AuthorizationStatus { get }
    func didConfirm(pin: String)
}

protocol AuthorizationViewModelDelegate: AnyObject {
    func didChangeStatus(_ status: AuthorizationStatus)
}

final class AuthorizationViewModel {
    
    private let authorizationManager: AuthorizationManagerProtocol
    
    var status: AuthorizationStatus {
        self.authorizationManager.status
    }
    
    weak var delegate: AuthorizationViewModelDelegate?
    
    init(authorizationManager: AuthorizationManagerProtocol = AuthorizationManager.shared) {
        self.authorizationManager = authorizationManager
    }
    
    func didConfirm(pin: String) {
        guard pin.count >= self.authorizationManager.mininumPasswordLength else {
            return
        }
        switch self.status {
        case .notSet:
            self.setPin(pin)
        case .unauthorized:
            self.authorize(pin)
        case .authorized:
            break
        }
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
