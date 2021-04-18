//
//  Supporting Func.swift
//  LittleThings
//
//  Created by Ting Becker on 4/17/21.
//

import UIKit

struct Action {
    
    static func createHapticFeedback(style:  UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
