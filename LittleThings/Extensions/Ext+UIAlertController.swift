//
//  UIAlertController.swift
//  One Three Five
//
//  Created by Seek, David on 12/10/20.
//

import UIKit

extension UIAlertController {
    
    func setBackgroundColor(color: UIColor) {
        if let bgView = self.view.subviews.first,
           let groupView = bgView.subviews.first,
           let contentView = groupView.subviews.first {
            contentView.backgroundColor = color
        }
    }

    static func showTipsInAlert(message: String) -> UIAlertController{
        let controller = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okay = UIAlertAction(title: "Sounds Good!", style: .cancel)
        controller.addAction(okay)
        controller.view.tintColor = Constants.blackWhite
        return controller
    }
    
    static func addTask(onTap: @escaping (Bool) -> Void) -> UIAlertController {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let edit = UIAlertAction(title: "Edit", style: .default) { _ in
            onTap(true)}
        let swap = UIAlertAction(title: "Swap", style: .default) { _ in
            onTap(false)}
        
        controller.addAction(cancel)
        controller.addAction(edit)
        controller.addAction(swap)
        
        controller.view.tintColor = Constants.blackWhite
        return controller
    }
    
    
//    static func logUserOut(onTap: @escaping (Bool) -> Void) -> UIAlertController {
//        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
//        let logOut = UIAlertAction(title: "Log out", style: .default) { _ in
//            onTap(true)}
//        let clearAllDone = UIAlertAction(title: "Clear Done", style: .destructive) { (_) in
//            onTap(false)}
//
//        controller.addAction(cancel)
//        controller.addAction(logOut)
//        controller.addAction(clearAllDone)
//
//        controller.view.tintColor = Constants.blackWhite
//        return controller
//    }
}
