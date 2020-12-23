//
//  AppInfoViewController.swift
//  One Three Five
//
//  Created by Tee Becker on 12/10/20.
//

import UIKit

class AppInfoViewController: UIViewController {
    
    //MARK: - IB Properties
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var detailTextLabel: UILabel!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureTapGesture()
        
    }
    
    //MARK: - Selector
    @objc func tapToDismissVC(){
        dismiss(animated: true)
    }
    
    
    //MARK: - Privates
    private func configureUI(){
        view.backgroundColor = Constants.offBlack202020
        
    }
    
    private func configureTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToDismissVC))
        view.addGestureRecognizer(tapGesture)
    }
}
