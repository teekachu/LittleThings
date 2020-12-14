//
//  LoginViewController.swift
//  One Three Five
//
//  Created by Ting Becker on 12/12/20.
//

import UIKit

protocol AuthenticationDelegate: class{
    func authenticationComplete()
}

class LoginViewController: UIViewController {
    
    //  MARK: - Properties
    weak var delegate: AuthenticationDelegate?
    private var viewmodel = LoginViewModel()
    
    
    //  MARK: - IB Properties
    @IBOutlet weak var emailTFUnderline: UIImageView!
    @IBOutlet weak var pswdTFUnderline: UIImageView!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func loginButtonTapped(_ sender: Any) {
        print("I want to login")
    }
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        let vc = ResetPasswordViewController()
        vc.email = emailTextfield.text
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBOutlet weak var signInWithGoogle: UIButton!
    @IBAction func signInWithGoogleTapped(_ sender: Any) {
        print("I want to sign in with google")
    }
    @IBAction func signUpTapped(_ sender: Any) {
        let svc = SignUpViewController()
        svc.modalPresentationStyle = .overCurrentContext
        svc.modalTransitionStyle = .crossDissolve
        navigationController?.pushViewController(svc, animated: true)
    }
    
    
    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        addTapGestureToDismiss()
        notificationObserver()
    }
    
    
    //  MARK: - Selectors
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @objc func didBeginEditing(_ sender: UITextField){
        if sender == emailTextfield{
            emailTextfield.placeholder = nil
        } else {
            passwordTextfield.placeholder = nil
        }
    }
    
    @objc func didEndEditing(_ sender: UITextField) {
        emailTextfield.placeholder = "Email"
        passwordTextfield.placeholder = "Password"
    }
    
    @objc func textDidChange(_ sender: UITextField) {
        if sender == emailTextfield{
            viewmodel.email = emailTextfield.text
        } else {
            viewmodel.password = passwordTextfield.text
        }
        /// enables button and changes color based on criteria above
        updateForm()
    }
    
    
    //  MARK: - Privates
    private func configureUI(){
        navigationController?.navigationBar.isHidden = true
        
        emailTFUnderline.image = #imageLiteral(resourceName: "lines3").withRenderingMode(.alwaysOriginal)
        pswdTFUnderline.image = #imageLiteral(resourceName: "lines1").withRenderingMode(.alwaysOriginal)
        
        emailTextfield.keyboardType = .emailAddress
        emailTextfield.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.whiteSmoke.self])
        
        passwordTextfield.isSecureTextEntry = true
        passwordTextfield.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.whiteSmoke.self])
        
        loginButton.tintColor = Constants.mediumBlack3f3f3f
        
        let googleIconImage = #imageLiteral(resourceName: "googleLogo").withRenderingMode(.alwaysOriginal)
        signInWithGoogle.setImage(googleIconImage, for: .normal)
        signInWithGoogle.imageView?.contentMode = .scaleAspectFit
    }
    
    private func addTapGestureToDismiss(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(gesture)
    }
    
    private func notificationObserver(){
        emailTextfield.addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        passwordTextfield.addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        
        emailTextfield.addTarget(self, action: #selector(didEndEditing(_:)), for: .editingDidEnd)
        passwordTextfield.addTarget(self, action: #selector(didEndEditing(_:)), for: .editingDidEnd)
        
        emailTextfield.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextfield.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
}

//  MARK: - FormViewModel
extension LoginViewController: FormViewModel {
    func updateForm() {
        loginButton.isEnabled = viewmodel.shouldEnableButton
        loginButton.tintColor = viewmodel.buttonTitleColor
    }
}
