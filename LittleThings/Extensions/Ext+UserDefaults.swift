//
//  UserDefaults.swift
//  LittleThings
//
//  Created by Ting Becker on 2/8/21.
//

import Foundation

extension UserDefaults {
    static func exists(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
