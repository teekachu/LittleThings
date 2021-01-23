//
//  menuOption.swift
//  LittleThings
//
//  Created by Ting Becker on 12/24/20.
//

import Foundation
import UIKit

enum MenuOption: Int, CustomDebugStringConvertible, CaseIterable {
    
    /// Controls actual order of items in side menu
    
//    case supportDevelopment
    case settings
    case whatIs135
    case shareWithFriends
    case sendSuggestions
    case reportBug
    case about
    case clearDone
    case logOut
    
    var image: UIImage {
        switch self {
//        case .supportDevelopment: return UIImage(systemName: "dollarsign.circle") ?? UIImage()
        case .shareWithFriends: return UIImage(systemName: "person.3.fill") ?? UIImage()
        case .sendSuggestions: return UIImage(systemName: "envelope") ?? UIImage()
        case .whatIs135: return UIImage(systemName: "questionmark") ?? UIImage()
        case .reportBug: return UIImage(systemName: "ladybug.fill") ?? UIImage()
        case .about: return UIImage(systemName: "exclamationmark.square") ?? UIImage()
        case .clearDone: return UIImage(systemName: "trash.fill") ?? UIImage()
        case .logOut: return UIImage(systemName: "xmark") ?? UIImage()
        case .settings:
            return UIImage(systemName: "gear") ?? UIImage()
        }
    }
    
    var debugDescription: String {
        switch self {
//        case .supportDevelopment: return "Support Development "
        case .shareWithFriends: return "Share With Friends "
        case .sendSuggestions: return "Send Suggestions "
        case .whatIs135: return "What is the 1-3-5 rule "
        case .reportBug: return "Report Bug "
        case .about: return "About Us "
        case .clearDone: return "Clear Done "
        case .logOut: return "Log Out "
        case .settings: return "Settings"
        }
    }
    
}
