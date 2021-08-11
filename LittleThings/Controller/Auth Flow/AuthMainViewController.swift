//
//  AuthMainViewController.swift
//  LittleThings
//
//  Created by Ting Becker on 1/10/21.
//

import UIKit

protocol AuthenticationDelegate: class{
    func authenticationComplete()
}

protocol AuthMainViewControllerDelegate: class{
    func didTapActionButton()
    func didTapBackToLoginButton()
}

class AuthMainViewController: UIViewController {
    
    //  MARK: - Properties
    private let authManager: AuthManager
    weak var delegate: AuthenticationDelegate?

    init(authManager: AuthManager) {
        self.authManager = authManager
        super.init(nibName: "AuthMainViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  MARK: - IB Properties
    @IBOutlet weak var getStartedButton: UIButton!
    @IBAction func getStartTapped(_ sender: Any) { handleLogin() }
    
    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //  MARK: - Privates
    private func configureUI(){
        navigationController?.navigationBar.isHidden = true
        getStartedButton.layer.cornerRadius = 15
    }
    
    private func handleLogin(){
        let controller = LoginViewController(authManager: authManager)
        controller.createAccountDelegate = self
        controller.resetPasswordDelegate = self
        controller.authenticateDeligate = self
        present(a: controller)
    }
}

//  MARK: - Extensions
extension AuthMainViewController: AuthMainViewControllerDelegate {
    func didTapBackToLoginButton() {
        dismiss(animated: true) {[weak self] in
            self?.handleLogin()
        }
    }
    
    func didTapActionButton() {
        dismiss(animated: true) {
            self.delegate?.authenticationComplete()
        }
    }
}

extension AuthMainViewController: ResetPasswordDelegate {
    func resetPasswordTapped(with email: String) {
        let vc = ResetPasswordViewController(authManager: authManager)
        vc.email = email
        present(a: vc)
    }
}

extension AuthMainViewController: createAccountDelegate {
    func didTapCreateAccount() {
        let vc = SignUpViewController(authManager: authManager)
        vc.authenticateDeligate = self
        present(a: vc)
    }
}
