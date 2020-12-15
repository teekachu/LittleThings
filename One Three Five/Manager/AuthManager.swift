//
//  AuthManager.swift
//  One Three Five
//
//  Created by Ting Becker on 12/14/20.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore
import GoogleSignIn

typealias DatabaseCompletion = ((Error?, DatabaseReference) -> Void)
let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("Users")

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
    
    
    static func registerUserWithFirestore(email: String, password: String, fullname: String, hasSeenOnboardingPage: Bool, completion: ((Error?) -> Void)?){
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("DEBUG: Error occured during creating user: \(error.localizedDescription)")
                completion!(error) /// enter into completion block with these 2 values, only error one matters in this case
                return
            }
            /// To save result in database. First set the unique identifier to the uid created by firebase for user.
            guard let uid = result?.user.uid else {return}
            
            /// create data dictionary / data structure. Don't need to save the pswd.
            let structure = [
                "email": email,
                "fullname": fullname,
                "hasSeenOnboardingPage": hasSeenOnboardingPage,
                "uid": uid
            ] as [String : Any]
            
            Firestore.firestore().collection("Users").document(uid).setData(structure, completion: completion)
        }
    }
    
    
    static func signInWithGoogle(didSignInFor user: GIDGoogleUser, completion: ((Error?) -> Void)?) {
        
        guard let auth = user.authentication else {return}
        let credential = GoogleAuthProvider.credential(withIDToken: auth.idToken,
                                                       accessToken: auth.accessToken)
        
        /// normal sign in process but with credential instead of email/pswd
        Auth.auth().signIn(with: credential) { (result, error) in
            
            /// handle error
            if let error = error {
                print("Debug: error when signing in with google credentials, \(error.localizedDescription) ")
                completion!(error)
                return
            }
            
            /// pull the user's id, email and fullname FROM google credentials
            guard let uid = result?.user.uid else{return}
            guard let email = result?.user.email else{return}
            guard let fullname = result?.user.displayName else{return}
            
            let values = [
                "email": email,
                "fullname": fullname,
                "hasSeenOnboardingPage": false
            ] as [String: Any]
            
            Firestore.firestore().collection("Users").document(uid).setData(values, completion: completion)
            
        }
    }
    
    
    static func signUserOut(){
        do{
            try Auth.auth().signOut()
        } catch {
            print("Error in signUserOut()")
        }
    }
}

//struct Service{
//
//
//
//    /// For real time database
//    static func registerUserWithFirebase(email: String, password: String, fullname: String, hasSeenOnboardingPage: Bool, completion: @escaping DatabaseCompletion){
//
//        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
//            if let error = error {
//                print("DEBUG: Error occured during creating user: \(error.localizedDescription)")
//                completion(error, REF_USERS) /// enter into completion block with these 2 values, only error  matters in this case
//                return
//            }
//            /// To save result in database. First set the unique identifier to the uid created by firebase for user.
//            guard let uid = result?.user.uid else {return}
//
//            /// create data dictionary / data structure. Don't need to save the pswd.
//            let structure = [
//                "email": email,
//                "fullname": fullname,
//                "hasSeenOnboardingPage": hasSeenOnboardingPage
//            ] as [String : Any]
//
//            REF_USERS.child(uid).updateChildValues(structure, withCompletionBlock: completion)
//        }
//    }
//
//    /// For Firestore
//    static func registerUserWithFirestore(email: String, password: String, fullname: String, hasSeenOnboardingPage: Bool, completion: ((Error?) -> Void)?){
//
//        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
//            if let error = error {
//                print("DEBUG: Error occured during creating user: \(error.localizedDescription)")
//                completion!(error) /// enter into completion block with these 2 values, only error one matters in this case
//                return
//            }
//            /// To save result in database. First set the unique identifier to the uid created by firebase for user.
//            guard let uid = result?.user.uid else {return}
//
//            /// create data dictionary / data structure. Don't need to save the pswd.
//            let structure = [
//                "email": email,
//                "fullname": fullname,
//                "hasSeenOnboardingPage": hasSeenOnboardingPage,
//                "uid": uid
//            ] as [String : Any]
//
//            Firestore.firestore().collection("Users").document(uid).setData(structure, completion: completion)
//        }
//    }
//
//
//    static func signInWithGoogle(didSignInFor user: GIDGoogleUser, completion: @escaping DatabaseCompletion){
//
//        guard let auth = user.authentication else {return}
//        let credential = GoogleAuthProvider.credential(withIDToken: auth.idToken,
//                                                       accessToken: auth.accessToken)
//
//        /// normal sign in process but with credential instead of email/pswd
//        Auth.auth().signIn(with: credential) { (result, error) in
//
//            /// handle error
//            if let error = error {
//                print("Debug: error when signing in with google credentials, \(error.localizedDescription) ")
//                completion(error, REF_USERS)
//                return
//            }
//
//            /// pull the user's id, email and fullname FROM google credentials
//            guard let uid = result?.user.uid else{return}
//            guard let email = result?.user.email else{return}
//            guard let fullname = result?.user.displayName else{return}
//
//            /// To check if this user exists as google sign in, if no, then save the structure in firebase.
//            /// make API call
//            REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
//                if !snapshot.exists(){
//
//                    print("DEBUG: User does not exist, create user")
//                    let structure = [
//                        "email": email,
//                        "fullname": fullname,
//                        "hasSeenOnboardingPage": false
//
//                    ] as [String: Any]
//
//                    REF_USERS.child(uid).updateChildValues(structure, withCompletionBlock: completion)
//
//                } else {
//                    /// basically do nothing
//                    print("DEBUG: User already exist")
//                    completion(error, REF_USERS.child(uid))
//                }
//            }
//        }
//    }
//
//    /// Fetch from realtime database
//    static func fetchUser(completion: @escaping (User) -> Void) {
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//
//        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
//            //            print("Debug snapshot Key: \(snapshot.key)")
//            //            print("Debug snapshot value: \(snapshot.value)")
//
//            let uid = snapshot.key
//
//            /// cast as dictionary because when fetched from database, its not exactly a dictionary and will not be recogized as one
//            guard let dictionary = snapshot.value as? [String: Any] else {return}
//
//            /// make an instance of that user with information pulled from the database
//            let user = User(uid: uid, dictionary: dictionary)
//
//            /// escape with the user info
//            completion(user)
//        }
//    }
//
//
//    /// Fetch from Firestore
//    static func fetchUserFromFirestore(completion: @escaping (User) -> Void){
//        guard let uid = Auth.auth().currentUser?.uid else{return}
//
//        Firestore.firestore().collection("Users").document(uid).getDocument { (snapshot, error) in
//            //            print("Debug: snapshot is \(snapshot?.data())")
//            guard let dictionary = snapshot?.data() else {return}
//            let user = User(dictionary: dictionary)
//            completion(user)
//        }
//    }
//
//
//    static func updateUserHasSeenOnboardingInDatabase(completion: @escaping (DatabaseCompletion)){
//        /// find the unique id of the current user
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//
//        /// use that current id to access the "hasSeenOnboardingPage" key, then set the value to true.
//        /// Once they are all done, execute the completion handler
//        REF_USERS.child(uid).child("hasSeenOnboardingPage").setValue(true, withCompletionBlock: completion)
//    }
//
//
//    static func resetPassword(for email: String, completion: SendPasswordResetCallback?) {
//        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
//
//    }
//

