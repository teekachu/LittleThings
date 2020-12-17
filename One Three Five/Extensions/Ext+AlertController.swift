//
//  Ext+AlertCont.swift
//  One Three Five
//
//  Created by Tee Becker on 12/8/20.
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

}
