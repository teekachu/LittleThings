//
//  AppInfoViewController.swift
//  One Three Five
//
//  Created by Tee Becker on 12/10/20.
//

import UIKit

class AppInfoViewController: UIViewController {
    
    //MARK: - IB Properties
    
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        tapToDismissVC()
    }
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    //MARK: - Selector
    private func tapToDismissVC(){
        dismiss(animated: true)
    }
    
    
    //MARK: - Privates
    private func configureUI(){
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = Constants.offBlack202020
    }
    
}
