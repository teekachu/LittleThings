//
//  ResetPasswordViewController.swift
//  One Three Five
//
//  Created by Ting Becker on 12/13/20.
//

import UIKit

protocol ResetPasswordViewControllerDelegate: class {
    func controllerDidResetPassword()
}

class ResetPasswordViewController: UIViewController {
    
    //  MARK: - Properties
    private var viewmodel = ResetPasswordViewModel()
    var email: String?
    weak var delegate: ResetPasswordViewControllerDelegate?
    
    
    //  MARK: - IB Properties
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBAction func resetButtonTapped(_ sender: Any) {
        dismissKeyboard()
        handleResetPassword()}
    
    @IBAction func goBackToLoginTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)}
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadEmail()
        notificationObserver()
        addGestureToDismiss()
        
    }
    
    
    //  MARK: - Selectors
    @objc public func dismissKeyboard(){
        view.endEditing(true)}
    
    @objc func didBeginEditing(_ sender: UITextField){
        if sender == emailTextfield{
            emailTextfield.placeholder = nil
        }
    }
    
    @objc func didEndEditing(_ sender: UITextField) {
        emailTextfield.placeholder = "Email"}
    
    @objc func textDidChange(_ sender: UITextField) {
        if sender == emailTextfield{
            viewmodel.email = emailTextfield.text
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
        
        resetButton.tintColor = Constants.mediumBlack3f3f3f
        resetButton.isEnabled = false
        
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
    
    // MARK: - Auth
    private func handleResetPassword(){
        
        email = emailTextfield.text
        guard let email = email else { return }
        showLottieAnimation(true)
        
        AuthManager.resetPassword(for: email) {[weak self](error) in
            self?.showLottieAnimation(false)
            
            if let error = error {
                self?.errorLabel.text = "\(error.localizedDescription)"
                print("DEBUG: error in handleResetPassword = \(error.localizedDescription)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    self?.errorLabel.text = ""
                }
                return
            }
            
            print("did reset password")
            self?.delegate?.controllerDidResetPassword()
        }
    }
}


//  MARK: - FormViewModel
extension ResetPasswordViewController: FormViewModel {
    
    func updateForm() {
        resetButton.isEnabled = viewmodel.shouldEnableButton
        resetButton.tintColor = viewmodel.buttonTitleColor
    }
}


//  MARK: - UITextfieldDelegate
extension ResetPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
