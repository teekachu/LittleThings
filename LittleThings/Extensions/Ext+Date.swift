//
//  DateExt.swift
//  One Three Five To do List
//
//  Created by Tee Becker on 11/30/20.
//

import UIKit

extension Date {
    
    func convertToString() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: self)
    }
    
    func convertToSimplifiedTimeString() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a, MMM d"
        return dateFormatter.string(from: self)
    }
    
}
