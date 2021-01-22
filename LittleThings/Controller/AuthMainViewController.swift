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
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var LoginButton: UIButton!
    
    @IBAction func loginTapped(_ sender: Any) {
        let controller = LoginViewController(authManager: authManager)
        controller.delegate = self
        controller.delegate2 = self
        present(a: controller)
    }
    
    @IBAction func signupTapped(_ sender: Any) {
        let controller = SignUpViewController(authManager: authManager)
        controller.delegate = self
        present(a: controller)}
    
    
    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    //  MARK: - Privates
    private func configureUI(){
        navigationController?.navigationBar.isHidden = true
        signupButton.layer.cornerRadius = 15
        LoginButton.layer.cornerRadius = 15
    }
}

//  MARK: - Extensions
extension AuthMainViewController: AuthMainViewControllerDelegate {
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
