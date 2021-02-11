//
//  AppDelegate.swift
//  One Three Five
//
//  Created by Tee Becker on 12/1/20.
//

import UIKit
import Firebase
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private var authManager: AuthManager?
    private var databaseManager: DatabaseManager?
    private var notificationsManager: NotificationsManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        // set up your background color view
        let colorView = UIView()
        colorView.layer.cornerRadius = 15
        
        // configure gradiant background
        colorView.backgroundColor = #colorLiteral(red: 0.2196078431, green: 0.2196078431, blue: 0.2196078431, alpha: 1)
        
        // use UITableViewCell.appearance() to configure
        // the default appearance of all UITableViewCells in your app
        UITableViewCell.appearance().selectedBackgroundView = colorView
        
        authManager = AuthManager(delegate: self)
//        databaseManager = DatabaseManager(delegate: self)
        databaseManager = DatabaseManager()
        let taskManager = TaskManager(authManager: authManager!, databaseManager: databaseManager!)
        notificationsManager = NotificationsManager(registerIn: application, delegate: self)
        let controller = TasksViewController(
            authManager: authManager!,
            taskManager: taskManager,
            notificationsManager: notificationsManager!,
            databaseManager: databaseManager!)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: controller)
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if UserDefaults.exists(key: "CountSwitchIsOn") {
            
            if UserDefaults.standard.bool(forKey: "CountSwitchIsOn") == false {
                // Hide
                UIApplication.shared.applicationIconBadgeNumber = 0
                
            } else {
                guard let userID = authManager?.userID else {return}
                databaseManager?.getBadgeCount(for: userID, onLoad: notificationsManager!.setBadge)
                return
            }
            
        } else {
            guard let userID = authManager?.userID else {return}
            databaseManager?.getBadgeCount(for: userID, onLoad: notificationsManager!.setBadge)
            return
        }
    }
    
}

// MARK: - NotificationManagerDelegate
extension AppDelegate: NotificationManagerDelegate {
    func notificationsManager(didReceiveToken token: String) {
        print("didReceiveToken \(token)")
        guard let userID = authManager?.userID else {
            return
        }
        let payload = ["gcmToken": token]
        databaseManager?.updateUser(payload, for: userID) { _ in
            // MARK: - TODO, handle Error appropriately
            print("Did update user gcmToken for userID \(userID)")
        }
    }
    
    func notificationsManager(didReceiveError error: Error) {
        print("didReceiveError \(error)")
    }
    
    func notificationsManager(didReceiveNotification payload: NotificationPayload, withResponse didRespond: Bool) {
        print("didReceiveNotification \(payload) withResponse: \(didRespond)")
    }
}

// MARK: - AuthManagerDelegate
extension AppDelegate: AuthManagerDelegate {
    func authManager(setUser data: [String : Any], for userID: String, onComplete: @escaping FirebaseCompletion) {
        databaseManager?.setUser(data, for: userID, onComplete: onComplete)
    }
    
    func authManager(updateUser data: [String : Any], for userID: String, onComplete: @escaping FirebaseCompletion) {
        databaseManager?.updateUser(data, for: userID, onComplete: onComplete)
    }
    
    func authManager(getDataFor userID: String, onCompletion: @escaping ([String : Any]) -> Void) {
        databaseManager?.getDataFor(userID, onCompletion: onCompletion)
    }
}

// MARK: - DatabaseManagerDelegate
//extension AppDelegate: DatabaseManagerDelegate {
//    func databaseManager(didSignalUserAuthenticationFor userID: String) {
//        databaseManager?.getBadgeCount(for: userID, onLoad: notificationsManager!.setBadge)
//    }
//}
