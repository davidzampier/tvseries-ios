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
        case .notSet:
            self.titleLabel.text = "Define a PIN code"
            self.confirmButton.setTitle("Confirm", for: .normal)
        case .unauthorized:
            self.isModalInPresentation = true
            self.titleLabel.text = "Enter your PIN code"
            self.confirmButton.setTitle("Unlock", for: .normal)
        case .authorized:
            break
        }
    }
    
    @IBAction func didTapConfirmButton(_ sender: Any) {
        guard let text = self.pinTextField.text else {
            return
        }
        self.viewModel.didConfirm(pin: text)
        
    }
    
    @IBAction func didTapUseFaceIDButton(_ sender: Any) {
        
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
}
