//
//  AuthenticationViewModel.swift
//  One Three Five
//
//  Created by Ting Becker on 12/12/20.
//

import UIKit

protocol AuthenticationViewModel {
    var formIsValid: Bool {get}
    var shouldEnableButton: Bool {get}
    var buttonTitleColor: UIColor {get}
    var buttonBackgroundColor: UIColor {get}
}

protocol SwapAuthenticationViewModel {
    var formIsValid: Bool {get}
    var shouldEnableButton: Bool {get}
    var buttonTitleColor: UIColor {get}
    var buttonLayerColor: UIColor {get}
}

protocol FormViewModel {
    func updateForm()
}

struct LoginViewModel: AuthenticationViewModel {
    
    var email: String?
    var password: String?
    
    var formIsValid: Bool{
        return email?.isEmpty == false
            && password?.isEmpty == false }
    
    var shouldEnableButton: Bool{ return formIsValid }

    var buttonTitleColor: UIColor {
        /// Color for true was Constants.whiteSmoke
        return formIsValid ? Constants.offBlack202020 : Constants.mediumBlack3f3f3f }
    
    var buttonBackgroundColor: UIColor {
        return formIsValid ? Constants.whiteSmoke : Constants.offBlack202020 }
}

struct RegistrationViewModel: AuthenticationViewModel{
    
    var email: String?
    var password: String?
    var fullname: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false
            && password?.isEmpty == false
            && fullname?.isEmpty == false }
    
    var shouldEnableButton: Bool { return formIsValid }
    
    var buttonTitleColor: UIColor {
        return formIsValid ? Constants.offBlack202020 : Constants.mediumBlack3f3f3f }
    
    var buttonBackgroundColor: UIColor {
        return formIsValid ? Constants.whiteSmoke : Constants.offBlack202020 }
}

struct ResetPasswordViewModel: AuthenticationViewModel{
    
    var email: String?

    var formIsValid: Bool{ return email?.isEmpty == false }
    
    var shouldEnableButton: Bool { return formIsValid }
    
    var buttonTitleColor: UIColor {
        return formIsValid ? Constants.offBlack202020 : Constants.mediumBlack3f3f3f }
    
    var buttonBackgroundColor: UIColor {
        return formIsValid ? Constants.whiteSmoke : Constants.offBlack202020 }
}

/// - Swap Screen
struct SwapTaskViewModel: SwapAuthenticationViewModel {
    
    var texts: String?

    var formIsValid: Bool{ return texts?.isEmpty == false
        && texts?.meetsCharCount(of: Constants.textCharacterCount) == true
        && texts?.trimmingCharacters(in: .whitespaces) != ""
    }
    
    var shouldEnableButton: Bool { return formIsValid }
    
    var buttonTitleColor: UIColor {
        return formIsValid ? Constants.blackWhite! : Constants.whiteOffblack!  }
    
    var buttonLayerColor: UIColor {
        return formIsValid ? Constants.swapCellBorder! : Constants.whiteOffblack!  }
    
}
    
