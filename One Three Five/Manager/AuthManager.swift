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
            print("Debug: snapshot is \(snapshot?.data())")
            
            guard let dictionary = snapshot?.data() else {return}
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
    
    
    static func updateUserHasSeenOnboardingInDatabase(completion: @escaping (FirebaseCompletion)){
        /// find the unique id of the current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let hasSeenOnboardingData = ["hasSeenOnboardingPage": true]
        
        REF_USERS.document(uid).updateData(hasSeenOnboardingData, completion: completion)
    }
}


