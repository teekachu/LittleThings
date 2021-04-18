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
    
    static let orangeFDB903 = UIColor(named: "OrangeTintFDB903")
    
    static let segmentBarBackground = UIColor(named: "segment background")
    
    static let smallTextNavBarColor = UIColor(named: "smalltext nav bar color")
    
    static let viewBackgroundWhiteSmoke = UIColor(named: "viewbackgroundWhitesmoke")
    
    static let whiteOffblack = UIColor(named: "white offblack")
    
    static let pickerLabelBackground = UIColor(named: "pickerLabelBackground")
    
    static let cellBorderColor = UIColor(named: "white mediumBlack")
    
    static let blackYellow = UIColor(named: "black yellow")
    
    static let bottomContainerBorder = UIColor(named: "gray offblack")
    
    static let brightOrange = UIColor(named: "orangeQuoteLabel")
    
    static let swapModeText = UIColor(named: "offblack white")
    
    static let swapCellBorder = UIColor(named: "swapCellBorder")
    
    static let settingsCellSelected = UIColor(named: "settingsCellSelected")
    
    static let normalBlackWhite = UIColor(named: "normalBW")
    
    static let normalWhiteBlack = UIColor(named: "normalWB")
    
    static let whiteSmoke: UIColor =  #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
    
    static let offBlack202020: UIColor =  #colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1254901961, alpha: 1)
    
    static let mediumBlack3f3f3f: UIColor = #colorLiteral(red: 0.2470588235, green: 0.2470588235, blue: 0.2470588235, alpha: 1)
    
    static let grayBlack707070: UIColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
    
    static let lightGrayCDCDCD: UIColor = #colorLiteral(red: 0.8039215686, green: 0.8039215686, blue: 0.8039215686, alpha: 1)
    
    static let innerYellowFCD12A: UIColor = #colorLiteral(red: 0.9882352941, green: 0.8196078431, blue: 0.1647058824, alpha: 1)
    
    static let webYellowFFDF6C: UIColor = #colorLiteral(red: 1, green: 0.8745098039, blue: 0.4235294118, alpha: 1)
    
    static let sidemenufontWhite: UIColor = #colorLiteral(red: 0.9333333333, green: 0.9843137255, blue: 0.9843137255, alpha: 1)
    
    //  MARK: - Fonts
    static let fontBold = "Avenir-Heavy"
    
    static let fontBoldItalic = "Avenir-HeavyOblique"
    
    static let fontMedium = "Avenir-Medium"
    
    static let fontItalic = "Avenir-LightOblique"
    
    static let titleTextFont = "Avenir-Heavy"
    
    static let detailSubtitleTextFont = "Avenir-HeavyOblique"
    
    static let avenirBlackSuperBold = "Avenir-Black"
    
    static let menuFont = "Avenir-Roman"
    
    static let textCharacterCount = 150
    
    // MARK: - Strings
    static let ruleOfThumb = "Consider a task Large if it takes about 3-4 hours to complete. Medium Tasks can take about 1-2 hours, and Small Tasks may take less than 30 minutes each. "
    
    static let swapScreenExplaination = """
        Swap mode's purpose is to focus on completing one existing task in exchange for another. When in swap mode, you cannot navigate around the app until the old task is "swapped" out.

        Simply enter the new task in the text bubble, tap on "Yes", exit the app if necessary, and get working.

        Once you are ready to swap, the old task will be moved to done, replaced by the new.
        """
    
    static let thankYouForYourPurchaseBase = """
        Hey there. Thank you so much for your love and support. This tip will allow me to continue working on LittleThings and improve her to be even better for you guys. I appreciate you so much for supporting my journey!

        Much love, Tee
        """
    
    static let thankYouForYourPurchaseAdv = """
        Hey there. Thank you so much for your love and support. This tip will allow me to continue learning new knowledge and strive to become a better developer. Thanks for investing in my future, I appreciate you to the moon and back!

        Much love, Tee
        """
}


// MARK: - Finish task strings
struct toastStrings {
    static let newTaskString = [
        "OMG food! Ugh I was getting a little hangry there.",
        "You got anymore of them tasks? I'm still a little hungry.",
        "Nom nom nom...",
        "New task added!",
        "Danggg, you are hella busy today.",
        "Feeeeeeed meeeeeeee!"
    ]
    
    static let doneString = [
        "Woop woop! One down, high five!",
        "Look at you being all productive and stuff!",
        "We got 99 problems and one more task ain't a thing.",
        "Go get em' tiger.",
        "Good job on wrapping this up!",
        "Thank you, NEXTTTTTT",
        "Byeeeeeee Felicia",
        "Done! Finished! Get it!",
        "Nice! I don't have arms or I'd give you a high five.",
        "Don't forget to clean out the trash can.",
        "Love that accomplishment for you."
    ]
    
    static let notDoneString = [
        "There is no shame in changing your mind.",
        "Dead task, RESURRECT!",
        "Still working on that? No problem!"
    ]
    
    static let updatedString = [
        "Updated",
        "Done-zo",
        "Grumble..."
    ]
}


// MARK: - Finish task strings
struct apperance {
    static let eyes = [
        "eyes1", "eyes2", "eyes3", "eyes4", "eyes5", "eyes6", "eyes7", "eyes8"
    ]
}


//  MARK: - Helper functions
struct Helper {
    static func getKeyboardHeight(notification: Notification) -> CGFloat {
        guard let keyboardHeight = (notification.userInfo? [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {return 0}
        return keyboardHeight
    }
    
}




