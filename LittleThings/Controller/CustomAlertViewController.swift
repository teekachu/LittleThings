//
//  CustomAlertViewController.swift
//  LittleThings
//
//  Created by Ting Becker on 12/29/20.
//

import UIKit

class CustomAlertViewController: UIViewController {

    var alertTitle: String
    var message: String
    
    init(alertTitle: String, alertMessage: String) {
        self.alertTitle = alertTitle
        self.message = alertMessage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  MARK: - IB Properties
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    
    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        alertView.layer.borderColor =
            Constants.bottomContainerBorder?.cgColor
    }
    
    //  MARK: - Selectors
    
    
    //  MARK: - Privates
    private func configureUI(){
        navigationController?.navigationBar.isHidden = true
        addBlurEffectToView(for: .systemUltraThinMaterial)
        
        titleLabel.text = alertTitle
        labelText.text = message
        alertView.backgroundColor = Constants.whiteOffblack
        alertView.layer.cornerRadius = 25
        alertView.layer.borderWidth = 1
        alertView.layer.borderColor =
            Constants.bottomContainerBorder?.cgColor
        
        dismissButton.setTitleColor(Constants.blackWhite, for: .normal)
        
    }
}

//  MARK: - Extensions
