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
    
    static func clearDoneTasks(onTap: @escaping (Bool) -> Void) -> UIAlertController {
        let controller = UIAlertController(title: nil, message: "Are you sure you want to clear all done tasks? ", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "No", style: .default)
        let delete = UIAlertAction(title: "Yes", style: .default) { (_) in
            onTap(true)}
        
        controller.addAction(cancel)
        controller.addAction(delete)
        
        controller.view.tintColor = Constants.blackWhite
        return controller
    }
    
    static func showAlertWithTextfield(onTap: @escaping (String, Bool) -> Void) -> UIAlertController {
        let controller = UIAlertController(title: nil, message: "What should we call you? ", preferredStyle: .alert)
        controller.addTextField()
        
        let cancel = UIAlertAction(title: "Cancel", style: .default)
        let update = UIAlertAction(title: "Update", style: .default) { (_) in
            guard let name = controller.textFields?[0].text else {return}
            onTap(name, true)
        }
        
        controller.addAction(cancel)
        controller.addAction(update)
        
        controller.view.tintColor = Constants.blackWhite
        return controller
    }
    
    static func showLogOutAlert(onTap: @escaping(Bool) -> Void) -> UIAlertController {
        let controller = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .default)
        let logout = UIAlertAction(title: "Logout", style: .default) { (_) in
            onTap(true)
        }
        controller.addAction(cancel)
        controller.addAction(logout)
        
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
