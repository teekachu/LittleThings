//
//  SettingsOption.swift
//  LittleThings
//
//  Created by Ting Becker on 1/13/21.
//

import Foundation
import UIKit

enum SettingsOption: Int, CaseIterable, CustomDebugStringConvertible {
    
    case changeName
    case privacyPolicy
    case termsCondition
//    case Language

    
    var image: UIImage {
        switch self {
        
        case .changeName:
            return UIImage(systemName: "person") ?? UIImage()
        case .privacyPolicy:
            return UIImage(systemName: "shield") ?? UIImage()
        case .termsCondition:
            return UIImage(systemName: "doc.text.fill") ?? UIImage()
//        case .Language:
//            return UIImage(systemName: "flag") ?? UIImage()

            
        }
    }
    var debugDescription: String {
        switch self {
        case .changeName: return "Change Name"
        case .privacyPolicy: return "Privacy Policy"
        case .termsCondition: return "Terms & Condition"
//        case .Language: return "Language"
//        case .exit: return "Exit"
        }
    }
}
