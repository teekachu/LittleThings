//
//  Ext+UIElements.swift
//  LittleThings
//
//  Created by Ting Becker on 4/21/21.
//

import UIKit

extension UITextField {
    func applyBorders() {
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8
        self.layer.borderColor = UIColor.white.cgColor
    }
}

extension UIButton {
    func applyButtonCustomization() {
        self.layer.cornerRadius = 15
        self.tintColor = Constants.mediumBlack3f3f3f
        self.backgroundColor = Constants.offBlack202020
    }
}
