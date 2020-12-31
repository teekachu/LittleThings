//
//  User.swift
//  One Three Five
//
//  Created by Ting Becker on 12/12/20.
//

import Foundation

struct User{
    let uid: String
    let email: String
    let fullname: String
    var hasSeenOnboardingPage: Bool  /// subject to change
    
    /// For firestore
    init(dictionary: [String: Any]){
        self.uid = dictionary["uid"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.hasSeenOnboardingPage = dictionary["hasSeenOnboardingPage"] as? Bool ?? false
    }
}
