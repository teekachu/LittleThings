//
//  Ext+UIViewController.swift
//  One Three Five
//
//  Created by Ting Becker on 12/12/20.
//

import UIKit
import Lottie

extension UIViewController {
    
    func showMessage(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showLottieAnimation(_ show: Bool){
        if show{
            let vc = LottieLoadingAnimationViewController()
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true)
            
        } else {
            dismiss(animated: true)
        }
    }
    
}
