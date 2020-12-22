//
//  Ext+String.swift
//  One Three Five
//
//  Created by Ting Becker on 12/12/20.
//

import UIKit

extension String {
    
    func meetsCharCount(of limit: Int) -> Bool {
        return self.count < limit
    }
}
