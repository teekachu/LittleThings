//
//  ResetPasswordViewController.swift
//  One Three Five
//
//  Created by Ting Becker on 12/13/20.
//

import UIKit

protocol ResetPasswordDelegate: class {
    func resetPasswordTapped(with email: String)
}

class ResetPasswordViewController: UIViewController {
    
    //  MARK: - Properties
    private let authManager: AuthManager
    private var viewmodel = ResetPasswordViewModel()
    var email: String?
    
    
    //  MARK: - IB Properties
    @IBOutlet weak var bottomContainerview: UIView!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBAction func resetButtonTapped(_ sender: Any) {
        dismissKeyboard()
        handleResetPassword()}
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    //  MARK: - Lifecycle
    init(authManager: AuthManager) {
        self.authManager = authManager
        super.init(nibName: "ResetPasswordViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadEmail()
        observeKeyboard()
        notificationObserver()
        addGestureToDismiss()
    }
    
    
    //  MARK: - Selectors
    @objc public func dismissKeyboard(){
        view.endEditing(true)}
    
    @objc func didBeginEditing(_ sender: UITextField){
        if sender == emailTextfield{
            emailTextfield.placeholder = "Email"
        }
    }
    
    @objc func didEndEditing(_ sender: UITextField) {
        emailTextfield.placeholder = "Email"}
    
    @objc func textDidChange(_ sender: UITextField) {
        if sender == emailTextfield {
            viewmodel.email = emailTextfield.text
        }
        /// enables button and changes color based on criteria above
        updateForm()
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        let keyboardHeight = Helper.getKeyboardHeight(notification: notification)
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveLinear) { [weak self] in
            self?.view.frame.origin.y = -keyboardHeight + 20
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
        self.view.frame.origin.y = 0
    }
    
    //  MARK: - Privates
    private func configureUI(){
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = UIColor.init(white: 0.3, alpha: 0.4)
        
        bottomContainerview.layer.cornerRadius = 35
        bottomContainerview.backgroundColor = Constants.offBlack202020
        
        emailTextfield.delegate = self
        emailTextfield.attributedPlaceholder = NSAttributedString (
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor : Constants.whiteSmoke.self])
        emailTextfield.becomeFirstResponder()
        
        resetButton.layer.cornerRadius = 15
        resetButton.tintColor = Constants.mediumBlack3f3f3f
        resetButton.backgroundColor = Constants.offBlack202020
        
        errorLabel.textColor = .red
        errorLabel.textAlignment = .center
    }
    
    private func addGestureToDismiss(){
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(ResetPasswordViewController.dismissKeyboard))
        gesture.direction = .down
        view.addGestureRecognizer(gesture)
    }
    
    private func notificationObserver(){
        emailTextfield.addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        emailTextfield.addTarget(self, action: #selector(didEndEditing(_:)), for: .editingDidEnd)
        emailTextfield.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    private func loadEmail(){
        guard let email = email else { return }
        emailTextfield.text = email
        viewmodel.email = email
        updateForm()
    }
    
    private func observeKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func resetPasswordComplete(){
        errorLabel.text = "We have sent an email to the email address provided, please follow instructions to retrive your password."
        errorLabel.textColor = .green
        resetButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {[weak self] in
            self?.errorLabel.text = ""
        }
    }
    
    // MARK: - Auth
    private func handleResetPassword(){
        
        email = emailTextfield.text
        guard let email = email else { return }
        showLottieAnimation(true)
        
        authManager.resetPassword(for: email) {[weak self](error) in
            
            self?.showLottieAnimation(false)
            
            if let error = error {
                self?.errorLabel.text = "\(error.localizedDescription)"
                print("DEBUG: error in handleResetPassword = \(error.localizedDescription)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self?.errorLabel.text = ""
                }
                
                return
            }
            self?.resetPasswordComplete()
        }
    }
}


//  MARK: - FormViewModel
extension ResetPasswordViewController: FormViewModel {
    
    func updateForm() {
        resetButton.isEnabled = viewmodel.shouldEnableButton
        resetButton.tintColor = viewmodel.buttonTitleColor
        resetButton.backgroundColor = viewmodel.buttonBackgroundColor
    }
}


//  MARK: - UITextfieldDelegate
extension ResetPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
