//
//  NotificationsManager.swift
//  LittleThings
//
//  Created by Seek, David on 1/21/21.
//

import UIKit
import UserNotifications
import Firebase

typealias NotificationPayload = [AnyHashable: Any]

protocol NotificationManagerDelegate: class {
    func notificationsManager(didReceiveToken token: String)
    func notificationsManager(didReceiveError error: Error)
    func notificationsManager(didReceiveNotification payload: NotificationPayload, withResponse didRespond: Bool)
}

class NotificationsManager: NSObject {

    private let delegate: NotificationManagerDelegate
    private let messageKey = "gcm.message_id"

    init(registerIn application: UIApplication,
         delegate: NotificationManagerDelegate) {

        self.delegate = delegate
        super.init()
        register(application)
    }

    // MARK: - Public

    // To be called once the user is logged in
    // and the databaseManager is ready to receive payloads
    public func publishCurrentToken() {
        Messaging.messaging().token { [weak self] token, error in
            guard error == nil else {
                self?.delegate.notificationsManager(didReceiveError: error!)
                return
            }
            guard let token = token else {
                return
            }
            self?.delegate.notificationsManager(didReceiveToken: token)
        }
    }

    // MARK: - Private

    // It's generally good practice, to call the registration
    // after the user has seen and acknowledged some kind of
    // explanation screen why they should accept notifications.
    // It drastically increases the chance of the user
    // being willing to receive them.
    private func register(_ application: UIApplication) {

        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        let options: UNAuthorizationOptions = [.alert, .badge, .sound]

        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        UNUserNotificationCenter.current().requestAuthorization(options: options) {_, _ in }

        DispatchQueue.main.async {
            application.registerForRemoteNotifications()
        }
    }

    private func didReceive(_ notification: UNNotification, withResponse didRespond: Bool = false) {
        let userInfo = notification.request.content.userInfo

        if userInfo[messageKey] != nil {
            delegate.notificationsManager(didReceiveNotification: userInfo, withResponse: didRespond)
        }
    }
}

extension NotificationsManager : UNUserNotificationCenterDelegate {

      // Receive displayed notifications for iOS 10 devices.
      func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  willPresent notification: UNNotification,
                                  withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

            didReceive(notification)
            completionHandler([[.alert, .sound]])
      }

      func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  didReceive response: UNNotificationResponse,
                                  withCompletionHandler completionHandler: @escaping () -> Void) {

            didReceive(response.notification, withResponse: true)
            completionHandler()
      }
}

// MARK: - MessagingDelegate
extension NotificationsManager: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        delegate.notificationsManager(didReceiveToken: fcmToken)
    }
}
