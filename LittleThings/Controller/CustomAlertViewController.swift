//
//  CustomAlertViewController.swift
//  LittleThings
//
//  Created by Ting Becker on 12/29/20.
//

import UIKit

class CustomAlertViewController: UIViewController {
    //  MARK: - Properties
    
    
    //  MARK: - IB Properties
    @IBOutlet weak var backgroundView: UIView!
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
    
    //  MARK: - Selectors
    
    
    //  MARK: - Privates
    private func configureUI(){
        navigationController?.navigationBar.isHidden = true
    
        addBlurEffectToView(for: .systemUltraThinMaterial)
//        backgroundView.backgroundColor = UIColor.init(white: 0.3, alpha: 0.3) 
        
        alertView.backgroundColor = Constants.whiteOffblack
        alertView.layer.cornerRadius = 25
        alertView.layer.borderWidth = 1
        alertView.layer.borderColor =
            Constants.bottomContainerBorder?.cgColor
        
        dismissButton.layer.cornerRadius = 15
        dismissButton.layer.borderWidth = 1
        dismissButton.layer.borderColor = Constants.bottomContainerBorder?.cgColor
        dismissButton.setTitleColor(Constants.blackWhite, for: .normal)
        dismissButton.backgroundColor = Constants.whiteOffblack
        
    }
}

//  MARK: - Extensions
