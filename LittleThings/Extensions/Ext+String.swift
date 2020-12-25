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
    
//    func addImageToString(imageName: String){
//        
//        // create an NSMutableAttributedString
//        let fullString = NSMutableAttributedString(string: "")
//        
//        let imageAttachment = NSTextAttachment()
//        imageAttachment.image = UIImage(systemName: imageName)
//        let image1String = NSAttributedString(attachment: imageAttachment)
//        
//        // add the NSTextAttachment wrapper to full string, then add text.
//        fullString.append(image1String)
//        
//        return fullString.append(NSAttributedString(string: self))
//        
//    }

}
