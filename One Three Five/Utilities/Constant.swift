//
//  Constant.swift
//  One Three Five To do List
//
//  Created by Tee Becker on 11/27/20.
//

//  MARK: Properties
//  MARK: Lifecycle
//  MARK: Selectors
//  MARK: Privates
//  MARK: Extensions

import UIKit

struct Constants {
    
    static let backgroundColor: UIColor = #colorLiteral(red: 0.3098039216, green: 0.3882352941, blue: 0.4039215686, alpha: 1)
    
    static let NavBarTintColor: UIColor = #colorLiteral(red: 0.9333333333, green: 0.9607843137, blue: 0.8588235294, alpha: 1)
    
    static let secondaryBackgroundColor: UIColor = #colorLiteral(red: 0.7215686275, green: 0.8470588235, blue: 0.8470588235, alpha: 1)
    
    static let plusButtonBackgroundColor: UIColor = #colorLiteral(red: 0.9960784314, green: 0.3725490196, blue: 0.3333333333, alpha: 1)
    
    static let greenColor: UIColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
    
    static let textFontName = "Avenir Next"
    
}

struct Helper {
    
    static func getKeyboardHeight(notification: Notification) -> CGFloat {
        guard let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {return 0}
        return keyboardHeight
    }
}

struct toastMessages {
    static let tooManyTasks = "Woah, thats more than your daily 1-3-5 goals. Why don't you try to empty your plates first. "
}


