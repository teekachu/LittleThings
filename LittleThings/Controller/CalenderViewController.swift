//
//  CalenderViewController.swift
//  LittleThings
//
//  Created by Ting Becker on 12/26/20.
//

import UIKit

class CalenderViewController: UIViewController {
    
    //  MARK: - Properties
    @IBOutlet weak var backgroundView: UIView!
    
    //  MARK: - IB Properties
    
    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        // Do any additional setup after loading the view.
    }
    
    //  MARK: - Selectors
    
    
    //  MARK: - Privates
    private func configureUI(){
        backgroundView.backgroundColor = UIColor.init(white: 0.3, alpha: 0.3)
    }
    
}


//  MARK: - Extensions
