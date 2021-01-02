//
//  SwapTaskViewController.swift
//  LittleThings
//
//  Created by Ting Becker on 12/31/20.
//

import UIKit

class SwapTaskViewController: UIViewController {
    
    //  MARK: - Properties
    
    
    //  MARK: - IB Properties
    
    
    //  MARK: - Lifecycle
    @IBAction func tappedSwapActionButton(_ sender: Any) {
        handleSwapAction()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //  MARK: - Selectors
    
    
    //  MARK: - Privates
    private func configureUI(){
        addBlurEffectToView(for: .systemUltraThinMaterial)
    }
    
    private func handleSwapAction(){
        dismiss(animated: true)
    }
    
    
}

//  MARK: - Extensions
