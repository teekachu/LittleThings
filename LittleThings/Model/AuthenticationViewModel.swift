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
        return formIsValid ? Constants.innerYellowFCD12A : Constants.mediumBlack3f3f3f }
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
        return formIsValid ? Constants.innerYellowFCD12A : Constants.mediumBlack3f3f3f }
}

struct ResetPasswordViewModel: AuthenticationViewModel{
    
    var email: String?

    var formIsValid: Bool{ return email?.isEmpty == false }
    
    var shouldEnableButton: Bool { return formIsValid }
    
    var buttonTitleColor: UIColor {
        return formIsValid ? Constants.innerYellowFCD12A : Constants.mediumBlack3f3f3f }
}
    
