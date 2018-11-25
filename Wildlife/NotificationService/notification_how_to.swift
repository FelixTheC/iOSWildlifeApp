//
//  notification_how_to.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 19.06.18.
//  Copyright © 2018 Felix Eisenmenger. All rights reserved.
//

import Foundation
import UserNotifications


//func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//    // Override point for customization after application launch
//    UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
//    registerForPushNotifications() <- important
//    return true
//}

func showNotification(contentTitle: String, contentSubtitle: String, contentBody: String) {
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    
    let content = UNMutableNotificationContent()
    content.title = contentTitle
    content.subtitle = contentSubtitle
    content.body = contentBody
    
    let request = UNNotificationRequest(identifier: "customNotify", content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { (error) in
        if error != nil {
            print(error)
        } else {
            print("notification")
        }
    }
}

//####IMPORTANT########
//must be included in AppDelegate
//func registerForPushNotifications() {
//    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { (granted, error) in
//        
//        guard granted else { return }
//    }
//}
//
//func getNotificationSettings() {
//    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
//        
//        guard settings.authorizationStatus == .authorized else {return}
//        DispatchQueue.main.async(execute: {
//            UIApplication.shared.registerForRemoteNotifications()
//        })
//    }
//}
