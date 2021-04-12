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
        case CNYAppIcon
        case rainbowAppIcon
        case bwAppIcon
        case yellowLTIcon
        case rainbowHeartAppIcon
        case blackCheckmarkAppIcon
    }
    
    func changeAppIcon(to appIcon: AppIcon) {
        application.setAlternateIconName(appIcon.rawValue)
    } 
    
}
