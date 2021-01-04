//
//  AboutUSViewController.swift
//  LittleThings
//
//  Created by Ting Becker on 1/3/21.
//

import UIKit

class AboutUSViewController: UIViewController {
    
    //  MARK: - Properties
    
    
    //  MARK: - IB Properties
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var gitHubButton: UIButton!
    @IBOutlet weak var linkedinButton: UIButton!
    @IBOutlet weak var imageStackView: UIStackView!
    @IBAction func exitButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func twitterButtonTapped(_ sender: Any) {
        print("show me twitter page")
    }
    @IBAction func gitHubButtonTapped(_ sender: Any) {
        print("show me github page")
    }
    @IBAction func linkedinButtonTapped(_ sender: Any) {
        print("show me linkedinPage")
    }
    
    
    
    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    //  MARK: - Selectors
    
    
    //  MARK: - Privates
    private func configureUI(){
        addBlurEffectToView(for: .systemThinMaterial)
        navigationController?.navigationBar.isHidden = true

        profileImageView.layer.cornerRadius = 35
        profileImageView.backgroundColor = .clear
        
        let arrayOfButtons: [UIButton] = [twitterButton, linkedinButton, gitHubButton]
        
        for each in arrayOfButtons{
            each.layer.borderWidth = 1
            each.backgroundColor = Constants.whiteOffblack
            each.layer.borderColor = Constants.cellBorderColor?.cgColor
            each.layer.cornerRadius = 15
        }
    }
    
}

//  MARK: - Extensions
