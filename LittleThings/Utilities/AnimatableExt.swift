//
//  AnimatableExt.swift
//  One Three Five To do List
//
//  Created by Tee Becker on 11/28/20.
//

import UIKit
import Loaf

protocol Animatable {
}

extension Animatable where Self: UIViewController{
    
    func showToast(state: Loaf.State, message: String, location: Loaf.Location = .top, duration: TimeInterval = 3 ){
        DispatchQueue.main.async {
            Loaf(message,
                 state: state,
                 location: location,
                 sender: self)
                .show(.custom(duration))
        }
    }
    
}
