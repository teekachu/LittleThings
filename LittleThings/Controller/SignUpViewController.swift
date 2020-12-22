//
//  SignUpViewController.swift
//  One Three Five
//
//  Created by Ting Becker on 12/13/20.
//

import UIKit

class SignUpViewController: UIViewController, Animatable {
    
    //  MARK: - Properties
    private var viewmodel = RegistrationViewModel()
    weak var delegate: AuthenticationDelegate?
    
    //  MARK: - IB Properties
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBAction func signUpButtonTapped(_ sender: Any) {
        dismissKeyboard()
        showLottieAnimation(true)
        handleSignup()
    }
    @IBAction func goBackToLoginTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var errorLabel: UILabel!
    
    
    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        addTapGestureToDismiss()
        notificationObserver()
        observeKeyboard()
    }
    
    
    //  MARK: - Selectors
    @objc public func dismissKeyboard(){
        view.endEditing(true) }
    
    @objc func didBeginEditing(_ sender: UITextField){
        if sender == emailTextfield{
            emailTextfield.placeholder = nil
        } else if sender == passwordTextfield {
            passwordTextfield.placeholder = nil
        } else {
            nameTextfield.placeholder = nil
        }
    }
    
    @objc func didEndEditing(_ sender: UITextField) {
        emailTextfield.placeholder = "Email"
        passwordTextfield.placeholder = "Password"
        nameTextfield.placeholder = "What should we call you?"
    }
    
    @objc func textDidChange(_ sender: UITextField) {
        if sender == emailTextfield{
            viewmodel.email = emailTextfield.text
        } else if sender == passwordTextfield {
            viewmodel.password = passwordTextfield.text
        } else {
            viewmodel.fullname = nameTextfield.text
        }
        /// enables button and changes color based on criteria above
        updateForm()
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        let keyboardHeight = Helper.getKeyboardHeight(notification: notification)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn) { [weak self] in
            self?.view.frame.origin.y = -keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
        self.view.frame.origin.y = 0
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
        
        nameTextfield.delegate = self
        nameTextfield.attributedPlaceholder = NSAttributedString(
            string: "What should we call you?",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.whiteSmoke.self])
        
        signUpButton.tintColor = Constants.mediumBlack3f3f3f
        signUpButton.isEnabled = false
        
        errorLabel.textColor = .red
        errorLabel.textAlignment = .center
        
    }
    
    private func addTapGestureToDismiss(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        view.addGestureRecognizer(gesture)
    }
    
    private func notificationObserver(){
        emailTextfield.addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        passwordTextfield.addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        nameTextfield.addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        
        emailTextfield.addTarget(self, action: #selector(didEndEditing(_:)), for: .editingDidEnd)
        passwordTextfield.addTarget(self, action: #selector(didEndEditing(_:)), for: .editingDidEnd)
        nameTextfield.addTarget(self, action: #selector(didEndEditing(_:)), for: .editingDidEnd)
        
        emailTextfield.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextfield.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        nameTextfield.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    private func observeKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Auth
    private func handleSignup(){
        guard let emailtf = emailTextfield.text else { return }
        guard let passwordtf = passwordTextfield.text else { return }
        guard let fullnametf = nameTextfield.text else { return }
        
        // create user in Firestore
        AuthManager.registerUserWithFirestore( email: emailtf, password: passwordtf,
            fullname: fullnametf, hasSeenOnboardingPage: false) {[weak self] (error) in
            
            self?.showLottieAnimation(false)
            
            if let error = error {
                self?.errorLabel.text = "\(error.localizedDescription)"
                print("DEBUG error in handleSignup(), \(error.localizedDescription) ")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    self?.errorLabel.text = ""
                }
                return
            }
            
            self?.delegate?.authenticationComplete()
        }
    }
}



//  MARK: - FormViewModel
extension SignUpViewController: FormViewModel {
    
    func updateForm() {
        signUpButton.isEnabled = viewmodel.shouldEnableButton
        signUpButton.tintColor = viewmodel.buttonTitleColor
    }
}


//  MARK: - UITextfieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
