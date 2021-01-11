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
    weak var delegate: AuthenticationDelegate?
    
    
    //  MARK: - IB Properties
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var LoginButton: UIButton!
    
    @IBAction func loginTapped(_ sender: Any) {
        let controller = LoginViewController()
        controller.delegate = self
        controller.delegate2 = self
        controller.modalPresentationStyle = .overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        present(controller, animated: true)}
    
    @IBAction func signupTapped(_ sender: Any) {
        let controller = SignUpViewController()
        controller.delegate = self
        controller.modalPresentationStyle = .overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        present(controller, animated: true)}
    
    
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
        let vc = ResetPasswordViewController()
        vc.email = email
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
}
