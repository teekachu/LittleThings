//
//  LoginViewController.swift
//  One Three Five
//
//  Created by Ting Becker on 12/12/20.
//

import UIKit
import Firebase
import GoogleSignIn

protocol AuthenticationDelegate: class{
    func authenticationComplete()
}

class LoginViewController: UIViewController, Animatable {
    
    //  MARK: - Properties
    private var viewmodel = LoginViewModel()
    weak var delegate: AuthenticationDelegate?
    
    
    //  MARK: - IB Properties
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBAction func loginButtonTapped(_ sender: Any) {
        dismissKeyboard()
        handleLogin()}
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        handleForgotPassword()}
    
    @IBOutlet weak var signInWithGoogle: UIButton!
    @IBAction func signInWithGoogleTapped(_ sender: Any) {
        handleGoogleLogin()}
    
    @IBAction func signUpTapped(_ sender: Any) {
        let svc = SignUpViewController()
        svc.delegate = delegate
        svc.modalPresentationStyle = .overCurrentContext
        svc.modalTransitionStyle = .crossDissolve
        navigationController?.pushViewController(svc, animated: true)}
    
    
    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        addTapGestureToDismiss()
        notificationObserver()
        configureGoogleLogIn()
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
        
        emailTextfield.delegate = self
        emailTextfield.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.whiteSmoke.self])
        
        
        passwordTextfield.isSecureTextEntry = true
        passwordTextfield.delegate = self
        passwordTextfield.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.whiteSmoke.self])
        
        /// same as not valid
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
    
    private func configureGoogleLogIn(){
        /// When GIDSignIn is called, show the viewcontroller for google signin
        GIDSignIn.sharedInstance()?.presentingViewController = self
        /// and make the viewcontroller the delegate for google signin
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    
    //MARK: - Auth
    private func handleLogin(){
        guard let email = emailTextfield.text else { return }
        guard let password = passwordTextfield.text else { return }
        showLottieAnimation(true)
        
        AuthManager.logUserInWith(email: email, password: password) {[weak self] (result) in
            self?.showLottieAnimation(false)
            
            switch result{
            case.failure(let error):
                DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
                    self?.errorLabel.text = "\(error.localizedDescription)"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self?.errorLabel.text = ""
                    }
                }
            case .success:
                print("DEBUG: handleLogin()successful for user: \(email)")
                self?.delegate?.authenticationComplete()
            }
        }
    }
    
    private func handleGoogleLogin(){
        GIDSignIn.sharedInstance().signIn()
    }
    
    private func handleForgotPassword(){
        let vc = ResetPasswordViewController()
        vc.email = emailTextfield.text
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        navigationController?.pushViewController(vc, animated: true)
    }
}


//  MARK: - FormViewModel
extension LoginViewController: FormViewModel {
    func updateForm() {
        loginButton.isEnabled = viewmodel.shouldEnableButton
        loginButton.tintColor = viewmodel.buttonTitleColor
    }
}

//  MARK: - GIDSignInDelegate
extension LoginViewController: GIDSignInDelegate{
    
    /// this gets called after user input their google account information into auth.
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error{
            print(error.localizedDescription)
            return
        }
        showLottieAnimation(true)
        
        AuthManager.signInWithGoogle(didSignInFor: user) {[weak self] (error) in
            self?.showLottieAnimation(false)
            
            if let error = error {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
                    self?.errorLabel.text = "\(error.localizedDescription)"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        self?.errorLabel.text = ""
                    }
                }
            }
            
            print("DEBUG: does this get called?")
            self?.delegate?.authenticationComplete()
        }
    }
}

//  MARK: - ResetPasswordViewControllerDelegate
extension LoginViewController: ResetPasswordViewControllerDelegate {
    func controllerDidResetPassword() {
        navigationController?.popViewController(animated: true)
        errorLabel.text = "We have sent an email to the email address provided, please follow instructions to retrive your password."
        errorLabel.textColor = .green
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {[weak self] in
            self?.errorLabel.text = ""
        }
    }
}


//  MARK: - UITextfieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
