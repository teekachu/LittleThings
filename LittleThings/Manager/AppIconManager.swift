//
//  AppIconManager.swift
//  LittleThings
//
//  Created by Ting Becker on 1/26/21.
//

import UIKit

class AppIconManager {
    
    let application = UIApplication.shared
    
    // same naming convention in the plist to refernce to actual files
    enum AppIcon: String {
//        case primaryAppIcon
        case CNYAppIcon
        case rainbowAppIcon
    }
    
    func changeAppIcon(to appIcon: AppIcon) {
        application.setAlternateIconName(appIcon.rawValue)
    } 
    
}
