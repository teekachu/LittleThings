//
//  TaskType.swift
//  One Three Five
//
//  Created by Tee Becker on 12/5/20.
//

import Foundation

enum TaskType: String, CaseIterable, Codable, CustomDebugStringConvertible {
    
    case one = "One large task"
    case three = "Three medium tasks"
    case five = "Five small tasks"
    
    var debugDescription: String {
        switch self {
        case .one: return "Large"
        case .three: return "Medium"
        case .five: return "Small"

        }
    }
    
}

