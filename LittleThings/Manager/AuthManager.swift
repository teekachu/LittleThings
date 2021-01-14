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

typealias FirebaseCompletion = ((Error?) -> Void)
let FS_REF = Firestore.firestore()
let REF_USERS = FS_REF.collection("Users")

struct AuthManager{
    
    static func logUserInWith(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    
    static func registerUserWithFirestore(email: String, password: String, fullname: String, hasSeenOnboardingPage: Bool, completion: @escaping FirebaseCompletion){
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("DEBUG: Error occured during creating user: \(error.localizedDescription)")
                completion(error)
                return
            }
            /// To save result in database. First set the unique identifier to the uid created by firebase for user.
            guard let uid = result?.user.uid else { return }
            
            /// create data dictionary / data structure. Don't need to save the pswd.
            let structure = [
                "email": email,
                "fullname": fullname,
                "hasSeenOnboardingPage": hasSeenOnboardingPage,
                "uid": uid
            ] as [String : Any]
            
            REF_USERS.document(uid).setData(structure, completion: completion)
        }
    }
    
    
    static func signInWithGoogle(didSignInFor user: GIDGoogleUser, completion: @escaping FirebaseCompletion) {
        
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
                
                let values = [
                    "email": email,
                    "fullname": fullname,
                    "hasSeenOnboardingPage": false,
                    "uid": uid
                ] as [String: Any]
                
                REF_USERS.document(uid).setData(values, completion: completion)
                
            } else {
                completion(nil)
            }
        }
    }
    
    
    static func resetPassword(for email: String, completion: FirebaseCompletion?) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
    
    
    static func signUserOut(){
        do{
            try Auth.auth().signOut()
        } catch {
            print("DEBUG: Error in signUserOut()")
        }
    }
    
    
    static func fetchUserUID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    /// fetch actual user
    static func fetchUserFromFirestore(completion: @escaping (User) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        
        REF_USERS.document(uid).getDocument { (snapshot, error) in
            print("Debug: snapshot is \(String(describing: snapshot?.data()))")
            
            guard let dictionary = snapshot?.data() else {return}
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
    
    
    static func updateUserHasSeenOnboardingInDatabase(completion: @escaping (FirebaseCompletion)) {
        /// find the unique id of the current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let hasSeenOnboardingData = ["hasSeenOnboardingPage": true]
        
        REF_USERS.document(uid).updateData(hasSeenOnboardingData, completion: completion)
    }
    
    
    static func updateUserName(with newName: String, completion: @escaping (FirebaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let fullname = ["fullname": newName]
        
        REF_USERS.document(uid).updateData(fullname, completion: completion)
    }
    
    
    static func signInWithApple(with nonce: String?, didSignInForUser authorization: ASAuthorization , completion: @escaping FirebaseCompletion) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            //            // Save authorised user ID for future reference
            //            UserDefaults.standard.set(appleIDCredential.user, forKey: "appleAuthorizedUserIdKey")
            
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
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            Auth.auth().signIn(with: credential) { (authDataResult, error) in
                if let error = error {
                    print("Error in sign in - \(error.localizedDescription)")
                    return
                }
                
                if authDataResult?.additionalUserInfo?.isNewUser == true {
                    
                    /// pull the user's id, email and fullname FROM google credentials
                    guard let uid = authDataResult?.user.uid else{
                        print("no uid")
                        return }
                    guard let email = authDataResult?.user.email else{
                        print("no email")
                        return }
                    let fullname = authDataResult?.user.displayName ?? "Achiever"
                    
                    
                    let values = [
                        "email": email,
                        "fullname": fullname,
                        "hasSeenOnboardingPage": false,
                        "uid": uid
                    ] as [String: Any]
                    
                    REF_USERS.document(uid).setData(values, completion: completion)
                    
                } else {
                    completion(nil)
                }
                
            }
        }
        
    }
}


