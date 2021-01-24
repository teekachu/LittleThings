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
    @IBAction func exitButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func twitterButtonTapped(_ sender: Any) {
        twitterTapped()
    }
    @IBAction func gitHubButtonTapped(_ sender: Any) {
        githubTapped()
    }
    @IBAction func linkedinButtonTapped(_ sender: Any) {
        linkedInTapped()
    }
    
    
    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        twitterButton.layer.borderColor = Constants.whiteOffblack?.cgColor
        linkedinButton.layer.borderColor = Constants.whiteOffblack?.cgColor
        gitHubButton.layer.borderColor = Constants.whiteOffblack?.cgColor
    }
    
    
    //  MARK: - Privates
    private func configureUI(){
        addBlurEffectToView(for: .systemThinMaterial)
        navigationController?.navigationBar.isHidden = true
        
        profileImageView.layer.cornerRadius = 35
        profileImageView.backgroundColor = .clear
        
        let arrayOfButtons: [UIButton] = [twitterButton, linkedinButton, gitHubButton]
        
        for each in arrayOfButtons{
            each.layer.borderWidth = 1
            each.backgroundColor = Constants.cellBorderColor
            each.layer.borderColor = Constants.whiteOffblack?.cgColor
            each.layer.cornerRadius = 15
        }
    }
    
    private func twitterTapped() {
        let application = UIApplication.shared
        let appURL = URL(string: "twitter://user?screen_name=Teekachu1")!
        let webURL = URL(string: "https://twitter.com/Teekachu1")!
        
        application.canOpenURL(appURL) ? application.open(appURL) : application.open(webURL)
        
    }
    
    private func githubTapped() {
        let application = UIApplication.shared
        let webURL = URL(string: "https://github.com/teekachu")!
        
        application.open(webURL)
        
    }
    
    private func linkedInTapped() {
        let application = UIApplication.shared
        let appURL = URL(string: "linkedin://profile?id=tingbecker")!
        let webURL = URL(string: "https://www.linkedin.com/in/tingbecker/")!
        
        application.canOpenURL(appURL) ? application.open(appURL) : application.open(webURL)
        
    }
    
}

//  MARK: - Extensions
