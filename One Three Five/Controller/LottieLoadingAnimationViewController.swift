//
//  LottieLoadingAnimationViewController.swift
//  One Three Five
//
//  Created by Ting Becker on 12/16/20.
//

import UIKit
import Lottie

class LottieLoadingAnimationViewController: UIViewController {

    //  MARK: - Properties
    
    //  MARK: - IB Properties
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var animationView: AnimationView!
    
    
    
    //  MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        backgroundView.backgroundColor = Constants.offBlack202020.withAlphaComponent(0.9)
    
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.9
        animationView.play(toProgress: 0.9)
        
    }
    
}

