//
//  iOSAppDelegate.swift
//  lido (iOS)
//
//  Created by Everett Wilber on 7/12/22.
//

import Foundation
import UIKit
import UserNotifications

class LidoAppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    @Published var deviceNotificationToken: Data?
    
    func application(_ application: UIApplication) -> Bool {
       // Override point for customization after application launch.you’re
       UIApplication.shared.registerForRemoteNotifications()
       return true
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken
                    deviceToken: Data) {
        DispatchQueue.main.async {
            self.deviceNotificationToken = deviceToken
            print("device token")
            print("ascii")
            print(String(data: self.deviceNotificationToken ?? Data(), encoding: .ascii) as Any)
            print("symbol")
            print(String(data: self.deviceNotificationToken ?? Data(), encoding: .symbol) as Any)
            print("utf8")
            print(String(data: self.deviceNotificationToken ?? Data(), encoding: .utf8) as Any)
            print(String(data: self.deviceNotificationToken ?? Data(), encoding: .ascii) as Any)
            print(String(data: self.deviceNotificationToken ?? Data(), encoding: .ascii) as Any)
            print(String(data: self.deviceNotificationToken ?? Data(), encoding: .ascii) as Any)
            print(String(data: self.deviceNotificationToken ?? Data(), encoding: .ascii) as Any)
            print(String(data: self.deviceNotificationToken ?? Data(), encoding: .ascii) as Any)
        }
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError
                    error: Error) {
       // Try again later.
    }
}
