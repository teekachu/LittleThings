//
//  AboutUSViewController.swift
//  LittleThings
//
//  Created by Ting Becker on 1/3/21.
//

import UIKit

class AboutUSViewController: UIViewController {
    
    //  MARK: - Properties
    var stacks = [UIStackView]()
    
    //  MARK: - IB Properties
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var twitterStack: UIStackView!
    @IBOutlet weak var githubStack: UIStackView!
    @IBOutlet weak var linkedinStack: UIStackView!
    
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
        if !stacks.isEmpty{
            stacks.map{$0.setBorderColorForObject(using: Constants.whiteOffblack!)}
        }
    }
    
    
    //  MARK: - Privates
    private func configureUI(){
        addBlurEffectToView(for: .systemThinMaterial)
        navigationController?.navigationBar.isHidden = true
        
        profileImageView.layer.cornerRadius = 35
        profileImageView.backgroundColor = .clear
        
        stacks = [twitterStack, githubStack, linkedinStack]
        
        for each in stacks {
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
