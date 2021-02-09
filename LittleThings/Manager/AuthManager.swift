//
//  AuthManager.swift
//  One Three Five
//
//  Created by Ting Becker on 12/14/20.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import AuthenticationServices

typealias FirebaseCompletion = (Error?) -> Void
protocol AuthManagerDelegate: class {
    func authManager(setUser data: [String : Any], for userID: String, onComplete: @escaping FirebaseCompletion)
    func authManager(updateUser data: [String : Any], for userID: String, onComplete: @escaping FirebaseCompletion)
    func authManager(getDataFor userID: String, onCompletion: @escaping ([String : Any]) -> Void)
}

struct AuthManager {
    
    private let delegate: AuthManagerDelegate
    
    init(delegate: AuthManagerDelegate) {
        self.delegate = delegate
    }
    
    public var userID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    public var isUserLoggedIn: Bool {
        return userID != nil
    }
    
    public func logUserInWith(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    public func registerUserWithFirestore(email: String, password: String, fullname: String, hasSeenOnboardingPage: Bool, completion: @escaping FirebaseCompletion) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("DEBUG: Error occured during creating user: \(error.localizedDescription)")
                completion(error)
                return
            }
            /// To save result in database. First set the unique identifier to the uid created by firebase for user.
            guard let uid = result?.user.uid else { return }
            
            /// create data dictionary / data structure. Don't need to save the pswd.
            let payload = [
                "email": email,
                "fullname": fullname,
                "hasSeenOnboardingPage": hasSeenOnboardingPage,
                "uid": uid
            ] as [String : Any]
            
            delegate.authManager(setUser: payload, for: uid, onComplete: completion)
        }
    }
    
    public func signInWithGoogle(didSignInFor user: GIDGoogleUser, completion: @escaping FirebaseCompletion) {
        
        guard let auth = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: auth.idToken,
                                                       accessToken: auth.accessToken)
        
        /// normal sign in process but with credential instead of email/pswd
        Auth.auth().signIn(with: credential) { (result, error) in
            
            /// handle error
            if let error = error {
                print("DEBUG: error in signInWithGoogle(), \(error.localizedDescription) ")
                return
            }
            
            /// check if user exists
            if result?.additionalUserInfo?.isNewUser == true{
                
                /// pull the user's id, email and fullname FROM google credentials
                guard let uid = result?.user.uid else{ return }
                guard let email = result?.user.email else{ return }
                guard let fullname = result?.user.displayName else{ return }
                
                let payload = [
                    "email": email,
                    "fullname": fullname,
                    "hasSeenOnboardingPage": false,
                    "uid": uid
                ] as [String: Any]
                
                delegate.authManager(setUser: payload, for: uid, onComplete: completion)
                
            } else {
                completion(nil)
            }
        }
    }
    
    public func resetPassword(for email: String, completion: FirebaseCompletion?) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
    
    public func signUserOut(){
        do{
            
            try Auth.auth().signOut()
            
        } catch {
            print("DEBUG: Error in signUserOut()")
        }
    }
    
    /// fetch actual user
    public func fetchUserFromFirestore(completion: @escaping (User) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        delegate.authManager(getDataFor: uid) { data in
            let user = User(dictionary: data)
            completion(user)
        }
    }
    
    public func updateUserHasSeenOnboardingInDatabase(completion: @escaping (FirebaseCompletion)) {
        /// find the unique id of the current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let payload = ["hasSeenOnboardingPage": true]
        delegate.authManager(updateUser: payload, for: uid, onComplete: completion)
    }
    
    public func updateUserName(with newName: String, completion: @escaping (FirebaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let payload = ["fullname": newName]
        delegate.authManager(updateUser: payload, for: uid, onComplete: completion)
    }
    
    public func signInWithApple(with nonce: String?, didSignInForUser authorization: ASAuthorization, completion: @escaping FirebaseCompletion) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard let nonce = nonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            // Initialize a Firebase credential.
            let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            
            Auth.auth().signIn(with: firebaseCredential) { (authResult, error) in
                if let error = error {
                    print("Error in sign in - \(error.localizedDescription)")
                    return
                }
                
                if authResult?.additionalUserInfo?.isNewUser == true {
                    
                    /// pull the user's id, email and fullname FROM  credentials
                    guard let uid = authResult?.user.uid else{
                        print("Debug: Unable to get uid from Apple Login")
                        return }
                    
                    guard let email = authResult?.user.email else{
                        print("Debug: Unable to get email from Apple Login")
                        return }
                    
                    let fullname = authResult?.user.displayName ?? "Task Destroyer"
                    
                    let payload = [
                        "email": email,
                        "fullname": fullname,
                        "hasSeenOnboardingPage": false,
                        "uid": uid
                    ] as [String: Any]
                    
                    delegate.authManager(setUser: payload, for: uid, onComplete: completion)
                    
                } else {
                    
                    completion(nil)
                }
            }
        }
    }
}


