//
//  Ext+UIViewController.swift
//  One Three Five
//
//  Created by Ting Becker on 12/12/20.
//

import UIKit
//import JGProgressHUD

extension UIViewController {
    //    static let hud = JGProgressHUD(style: .dark)
    
    //    func showLoader(_ show: Bool) {
    //        view.endEditing(true)
    //
    //        if show {
    //            UIViewController.hud.show(in: view)
    //        } else {
    //            UIViewController.hud.dismiss()
    //        }
    //    }
    //
    
    func configureGradientBackground(color1: UIColor, color2: UIColor) {
        let gradient = CAGradientLayer()
        gradient.colors = [color1, color2]
        gradient.locations = [0, 1]
        view.layer.addSublayer(gradient)
        gradient.frame = view.frame
    }
    
    func showMessage(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
