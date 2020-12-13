//
//  Constant.swift
//  One Three Five To do List
//
//  Created by Tee Becker on 11/27/20.
//

//  MARK: - Properties
//  MARK: - IB Properties
//  MARK: - Lifecycle
//  MARK: - Selectors
//  MARK: - Privates
//  MARK: - Extensions

import UIKit


struct Constants {
    
    //  MARK: - Colors
    static let addTaskButton = UIColor(named: "addTaskButton")
    
    static let blackBlack = UIColor(named: "black black")
    
    static let blackWhite = UIColor(named: "black white")
    
    static let blueDoneCellText = UIColor(named: "blue Blue")
    
    static let buttonContainerBackground = UIColor(named: "bottonContainerBackground")
    
    static let cellColorWhiteGray = UIColor(named: "cellColor white Gray")
    
    static let navBarQuoteTextColor = UIColor(named: "Navbar quote text color")
    
    static let navBarColor = UIColor(named: "navBarColor")
    
    static let orangeEEAE45 = UIColor(named: "OrangeTintEEAE45")
    
    static let segmentBarBackground = UIColor(named: "segment background")
    
    static let smallTextNavBarColor = UIColor(named: "smalltext nav bar color")
    
    static let viewBackgroundWhiteSmoke = UIColor(named: "viewbackgroundWhitesmoke")
    
    static let whiteOffblack = UIColor(named: "white offblack")
    
    static let pickerLabelBackground = UIColor(named: "pickerLabelBackground")
    
    static let cellBorderColor = UIColor(named: "white mediumBlack")
    
    static let blackYellow = UIColor(named: "black yellow")
    
    static let bottomContainerBorder = UIColor(named: "gray offblack")
    
    static let brightOrange = UIColor(named: "orangeQuoteLabel")
    
//    static let orangeTintColorEEAE45:UIColor = #colorLiteral(red: 0.9333333333, green: 0.6823529412, blue: 0.2705882353, alpha: 1)
    
    static let whiteSmoke: UIColor =  #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
    
    static let offBlack202020: UIColor =  #colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1254901961, alpha: 1)
    
    static let mediumBlack3f3f3f: UIColor = #colorLiteral(red: 0.2470588235, green: 0.2470588235, blue: 0.2470588235, alpha: 1)
    
    static let grayBlack707070: UIColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
    
    static let lightGrayCDCDCD: UIColor = #colorLiteral(red: 0.8039215686, green: 0.8039215686, blue: 0.8039215686, alpha: 1)
    
    static let innerYellowFCD12A: UIColor = #colorLiteral(red: 0.9882352941, green: 0.8196078431, blue: 0.1647058824, alpha: 1)
    
    static let webYellowFFDF6C: UIColor = #colorLiteral(red: 1, green: 0.8745098039, blue: 0.4235294118, alpha: 1)
    
    //  MARK: - Fonts
    static let fontBold = "Palatino-Bold"
    
    static let fontBoldItalic = "Palatino-BoldItalic"
    
    static let fontMedium = "Palatino-Roman"
    
    static let fontItalic = "Palatino-Italic "
    
    static let titleTextFont = "Palatino-Bold"
    
    static let detailSubtitleTextFont = "Palatino-BoldItalic"
    
}


//  MARK: - Toast messages
struct toastMessages {
    static let tooManyTasks = "Woah, thats more than your daily 1-3-5 goals. Why don't you try to empty your plates first. "
    
    static let cannotMarkCompleted = "Hmm, something is wrong. I can't seem to make this task completed. Please try again later"
    
    static let uhOhErr = "Uh Oh, something went wrong..."
}


//  MARK: - Helper functions
struct Helper {
    
    static func getKeyboardHeight(notification: Notification) -> CGFloat {
        guard let keyboardHeight = (notification.userInfo? [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {return 0}
        return keyboardHeight
    }
    
}




