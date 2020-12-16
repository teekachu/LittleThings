//
//  LottieLoadingAnimationViewController.swift
//  One Three Five
//
//  Created by Ting Becker on 12/16/20.
//

import UIKit
import Lottie

class LottieLoadingAnimationViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    
    //  MARK: - IB Properties
    @IBOutlet weak var animationView: AnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        // Do any additional setup after loading the view.
    }


    private func configureUI(){
        navigationController?.navigationBar.isHidden = true
        
        backgroundView.backgroundColor = Constants.offBlack202020.withAlphaComponent(0.9)
        
        animationView?.backgroundColor = Constants.offBlack202020
        animationView?.contentMode = .scaleAspectFit
        animationView?.loopMode = .loop
        animationView?.animationSpeed = 0.9
        animationView?.play()
    }

    
}

