//
//  SettingsOption.swift
//  LittleThings
//
//  Created by Ting Becker on 1/13/21.
//

import Foundation
import UIKit

enum SettingsOption: Int, CaseIterable, CustomDebugStringConvertible {
    
    //    case supportDevelopment
    case whatIs135
    case shareWithFriends
    case sendSuggestions
    case about
    case privacyPolicy
    case termsCondition
    case logOut
    
    
    var image: UIImage {
        switch self {
        
        //        case .supportDevelopment: return UIImage(systemName: "dollarsign.circle") ?? UIImage()
        case .whatIs135: return UIImage(systemName: "questionmark") ?? UIImage()
        case .shareWithFriends: return UIImage(systemName: "person.2.fill") ?? UIImage()
        case .sendSuggestions: return UIImage(systemName: "envelope") ?? UIImage()
        case .about: return UIImage(systemName: "exclamationmark.square") ?? UIImage()
        case .privacyPolicy: return UIImage(systemName: "shield.lefthalf.fill") ?? UIImage()
        case .termsCondition: return UIImage(systemName: "doc.text") ?? UIImage()
        case .logOut: return UIImage(systemName: "xmark") ?? UIImage()
            
        }
        
        
    }
    var debugDescription: String {
        switch self {
        
        //        case .supportDevelopment: return "Support Development "
        case .whatIs135: return "What is the 1-3-5 rule "
        case .shareWithFriends: return "Share With Friends "
        case .sendSuggestions: return "Send Suggestions "
        case .about: return "About Us"
        case .privacyPolicy: return "Privacy Policy"
        case .termsCondition: return "Terms & Condition"
        case .logOut: return "Log Out "
        }
    }
}
