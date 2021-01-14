//
//  LoginViewController.swift
//  One Three Five
//
//  Created by Ting Becker on 12/12/20.
//

import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices
import CryptoKit


class LoginViewController: UIViewController, Animatable {
    
    //  MARK: - Properties
    private var viewmodel = LoginViewModel()
    weak var delegate: AuthMainViewControllerDelegate?
    weak var delegate2: ResetPasswordDelegate?
    fileprivate var currentNonce: String?
    
    //  MARK: - IB Properties
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true)}
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        dismissKeyboard()
        handleLogin()}
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        handleForgotPassword()}
    
    @IBOutlet weak var signInWithGoogle: UIButton!
    @IBAction func signInWithGoogleTapped(_ sender: Any) {
        handleGoogleLogin()}
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    
    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        observeKeyboard()
        addGestureToDismiss()
        notificationObserver()
        configureGoogleLogIn()
        configureLoginWithApple()
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
        updateForm()
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        let keyboardHeight = Helper.getKeyboardHeight(notification: notification)

        UIView.animate(withDuration: 0.4, delay: 0, options: .curveLinear) { [weak self] in
            self?.view.frame.origin.y = -keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
        self.view.frame.origin.y = 0
    }
    
    @objc func appleSignInTapped(_ sender: UIButton) {
        performSignin()
    }
    
    //  MARK: - Privates
    private func configureUI(){
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = UIColor.init(white: 0.3, alpha: 0.4)
        
        bottomContainerView.layer.cornerRadius = 35
        bottomContainerView.backgroundColor = Constants.offBlack202020
        
        emailTextfield.delegate = self
        emailTextfield.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.whiteSmoke.self])
        emailTextfield.becomeFirstResponder()
        
        passwordTextfield.isSecureTextEntry = true
        passwordTextfield.delegate = self
        passwordTextfield.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.whiteSmoke.self])
        
        loginButton.layer.cornerRadius = 15
        loginButton.tintColor = Constants.mediumBlack3f3f3f
        loginButton.backgroundColor = Constants.offBlack202020
        
        let googleIconImage = #imageLiteral(resourceName: "googleLogo").withRenderingMode(.alwaysOriginal)
        signInWithGoogle.setImage(googleIconImage, for: .normal)
        signInWithGoogle.imageView?.contentMode = .scaleAspectFit
    }
    
    private func addGestureToDismiss(){
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        gesture.direction = .down
        bottomContainerView.addGestureRecognizer(gesture)
    }
    
    private func notificationObserver(){
        emailTextfield.addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        passwordTextfield.addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        
        emailTextfield.addTarget(self, action: #selector(didEndEditing(_:)), for: .editingDidEnd)
        passwordTextfield.addTarget(self, action: #selector(didEndEditing(_:)), for: .editingDidEnd)
        
        emailTextfield.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextfield.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    private func observeKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func configureGoogleLogIn(){
        /// When GIDSignIn is called, show the viewcontroller for google signin
        GIDSignIn.sharedInstance()?.presentingViewController = self
        /// and make the viewcontroller the delegate for google signin
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    private func configureLoginWithApple(){
        let button = ASAuthorizationAppleIDButton()
        buttonsStackView.addArrangedSubview(button)
        button.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
    }
    
    private func handleForgotPassword(){
        dismiss(animated: true) {
            guard let email = self.emailTextfield.text else {return}
            self.delegate2?.resetPasswordTapped(with: email)
        }
    }
    
    private func performSignin() {
        let request = createAppleIDRequest()
        let authController = ASAuthorizationController(authorizationRequests: [request])
        
        authController.delegate = self
        authController.presentationContextProvider = self
        
        authController.performRequests()
    }
    
    private func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        self.currentNonce = randomNonceString()
        request.nonce = sha256(currentNonce!)
        
        return request
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self?.errorLabel.text = ""
                    }
                }
            case .success:
                print("DEBUG: handleLogin()successful for user: \(email)")
                self?.delegate?.didTapActionButton()
            }
        }
        
    }
    
    private func handleGoogleLogin(){
        GIDSignIn.sharedInstance().signIn()
    }
    
}


//  MARK: - FormViewModel
extension LoginViewController: FormViewModel {
    func updateForm() {
        loginButton.isEnabled = viewmodel.shouldEnableButton
        loginButton.tintColor = viewmodel.buttonTitleColor
        loginButton.backgroundColor = viewmodel.buttonBackgroundColor
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self?.errorLabel.text = ""
                    }
                }
            }
            self?.delegate?.didTapActionButton()
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


//  MARK: - ASAuthorizationControllerDelegate
extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        guard let err = error as? ASAuthorizationError else { return }
        
        switch err.code {
        case .canceled:
            break
        case .failed:
            print("auth failed")
        case .invalidResponse:
            print("invalid response received from login")
        case .notHandled:
            print("Potentially due to internet failure during login")
        case .unknown:
            print("User didn't log their apple ID on device")
        @unknown default:
            print("unknown default")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            showLottieAnimation(true)
            
            AuthManager.signInWithApple(with: nonce, didSignInForUser: authorization) {[weak self] (error) in
                
                self?.showLottieAnimation(false)
                
                if let error = error {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
                        self?.errorLabel.text = "\(error.localizedDescription)"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            self?.errorLabel.text = ""
                        }
                    }
                }
                
                self?.delegate?.didTapActionButton()
            }
        
    }
    
}


//  MARK: - ASAuthorizationControllerPresentationContextProviding
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}


//  MARK: - Random nonce generator
extension LoginViewController {
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
