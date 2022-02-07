//
//  AuthorizationViewController.swift
//  TVSeries Guide
//
//  Created by David Zampier on 06/02/22.
//

import UIKit

class AuthorizationViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pinTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var useFaceIDButton: UIButton!
    
    var viewModel = AuthorizationViewModel()
    var completion: ((AuthorizationStatus) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.delegate = self
        self.setUpView()
    }
    
    private func setUpView() {
        switch self.viewModel.status {
        case .authorized:
            self.setUpViewForAuthorizedStatus()
        case .unauthorized:
            self.setUpViewForUnauthorizedStatus()
        }
    }
    
    private func setUpViewForUnauthorizedStatus() {
        switch self.viewModel.authorizationType {
        case .password:
            self.titleLabel.text = "Enter your PIN code"
            self.confirmButton.setTitle("Unlock", for: .normal)
            self.isModalInPresentation = true
        case .biometry:
            self.titleLabel.text = "Authorize with Biometrics"
            self.pinTextField.isHidden = true
            self.confirmButton.isHidden = true
            self.useFaceIDButton.isHidden = false
            self.useFaceIDButton.setTitle("Authorize", for: .normal)
            self.viewModel.didTapUseBiometryButton()
            self.isModalInPresentation = true
        case .none:
            self.titleLabel.text = "Define a PIN code"
            self.confirmButton.setTitle("Confirm", for: .normal)
            self.showBiometricsButton()
        }
    }
    
    private func setUpViewForAuthorizedStatus() {
        switch self.viewModel.authorizationType {
        case .password:
            self.titleLabel.text = "You are using a PIN code"
            self.confirmButton.setTitle("Remove", for: .normal)
            self.confirmButton.tintColor = .systemRed
            self.pinTextField.isHidden = false
            self.confirmButton.isHidden = false
        case .biometry:
            self.titleLabel.text = "You are using \(self.getBiometryName())"
            self.pinTextField.isHidden = true
            self.confirmButton.isHidden = false
            self.confirmButton.tintColor = .systemRed
            self.confirmButton.setTitle("Disable", for: .normal)
        case .none:
            break
        }
    }
    
    private func showBiometricsButton() {
        guard let type = self.viewModel.availableBiometricType else {
            self.useFaceIDButton.isHidden = true
            return
        }
        self.useFaceIDButton.isHidden = false
        switch type {
        case .touchID:
            self.useFaceIDButton.setTitle("Use TouchID instead", for: .normal)
        case .faceID:
            self.useFaceIDButton.setTitle("Use FaceID instead", for: .normal)
        }
    }
    
    private func getBiometryName() -> String {
        switch self.viewModel.availableBiometricType {
        case .touchID: return "TouchID"
        case .faceID: return "FaceID"
        default: return ""
        }
    }
    
    @IBAction func didTapConfirmButton(_ sender: Any) {
        guard self.viewModel.authorizationType != .biometry else {
            self.viewModel.didTapDisableBiometryButton()
            return
        }
        guard let text = self.pinTextField.text else {
            return
        }
        self.viewModel.didConfirm(pin: text)
    }
    
    @IBAction func didTapUseFaceIDButton(_ sender: Any) {
        self.viewModel.didTapUseBiometryButton()
    }
}


// MARK: - AuthorizationViewModelDelegate

extension AuthorizationViewController: AuthorizationViewModelDelegate {
    
    func didChangeStatus(_ status: AuthorizationStatus) {
        if status == .authorized {
            self.isModalInPresentation = false
            completion?(.authorized)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func didEnterWrongPassword() {
        let alert = UIAlertController(title: "Ops!", message: "Invalid PIN 🙁\n", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func didDisableAuthorization() {
        self.dismiss(animated: true, completion: nil)
    }
}
