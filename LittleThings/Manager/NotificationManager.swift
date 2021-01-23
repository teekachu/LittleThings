//
//  NotificationManager.swift
//  LittleThings
//
//  Created by Ting Becker on 1/19/21.
//

import UIKit
import UserNotifications

//class NotificationManager {
//    
//    var notifications = [Notification]()
//    
//    //    listScheduledNotifications(), so we can debug what notifications have been scheduled
//    func listScheduledNotifications() {
//        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
//            for notification in notifications {
//                print(notification)
//            }
//        }
//    }
//    
//    
//    //    requestAuthorization(), the private function that will prompt the app user to give permission to send local notifications
//    private func requestAuthorization() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
//            if granted == true && error == nil {
//                self.scheduleNotifications()
//            }
//        }
//    }
//    
//    
//    //    schedule(), the public function that will kick-off notification permissions and scheduling
//    func schedule() {
//        UNUserNotificationCenter.current().getNotificationSettings { settings in
//            switch settings.authorizationStatus {
//            case .notDetermined:
//                self.requestAuthorization()
//            case .authorized, .provisional:
//                self.scheduleNotifications()
//            default:
//                // do nothing, return error message to provide user feedback
//                //    errorMsg = "Please go to your phone settings and grant permission to receive notifications"
//                break
//            }
//        }
//    }
//    
//    
//    //    scheduleNotifications(), the private function that will iterate over the notifications property to schedule the local notifications
//    private func scheduleNotifications() {
//        for notification in notifications {
//            let content = UNMutableNotificationContent()
//            content.title = notification.title
//            content.body = notification.detail
//            content.sound = .default
//            
////            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.datetime, repeats: false)
//            
//            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
//            
//            UNUserNotificationCenter.current().add(request) { error in
//                
//                guard error == nil else { return }
//                
//                print("Notification scheduled! --- ID = \(notification.id)")
//            }
//        }
//    }
//}
//
//
//
