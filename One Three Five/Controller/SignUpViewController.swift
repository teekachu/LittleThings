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
    @IBOutlet weak var emailTFUnderline: UIImageView!
    @IBOutlet weak var pswdTFUnderline: UIImageView!
    @IBOutlet weak var nameTFUnderline: UIImageView!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBAction func signUpButtonTapped(_ sender: Any) {
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
    
    
    //  MARK: - Privates
    private func configureUI(){
        navigationController?.navigationBar.isHidden = true
        
        /// TODO: Update
        emailTFUnderline.image = #imageLiteral(resourceName: "lines1").withRenderingMode(.alwaysOriginal)
        pswdTFUnderline.image = #imageLiteral(resourceName: "lines3").withRenderingMode(.alwaysOriginal)
        nameTFUnderline.image = #imageLiteral(resourceName: "lines3").withRenderingMode(.alwaysOriginal)
        
        emailTextfield.keyboardType = .emailAddress
        emailTextfield.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.whiteSmoke.self])
        
        passwordTextfield.isSecureTextEntry = true
        passwordTextfield.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.whiteSmoke.self])
        
        nameTextfield.keyboardType = .default
        nameTextfield.attributedPlaceholder = NSAttributedString(
            string: "What should we call you?",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.whiteSmoke.self])
        
        signUpButton.tintColor = Constants.mediumBlack3f3f3f
        signUpButton.isEnabled = false
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
    
    // MARK: - Auth
    private func handleSignup(){
        guard let emailtf = emailTextfield.text else {return}
        guard let passwordtf = passwordTextfield.text else {return}
        guard let fullnametf = nameTextfield.text else {return}
        
        //        showLoader(true)
        
        // create user in Firestore
        AuthManager.registerUserWithFirestore(
            email: emailtf,
            password: passwordtf,
            fullname: fullnametf,
            hasSeenOnboardingPage: false) {[weak self] (error) in
            if let error = error {
                self?.showToast(state: .error, message: "Uh oh, \(error.localizedDescription)")
                return
            }
            self?.delegate?.authenticationComplete()
//            self?.dismiss(animated: true) {
//                print("DEBUG: This sign up page should dismiss now")
//            }
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