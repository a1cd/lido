//
//  AppDelegate.swift
//  lido
//
//  Created by Everett Wilber on 7/11/22.
//

import Foundation
import AppKit
import UserNotifications

class LidoAppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published var deviceNotificationToken: Data?
    
    func application(_ application: NSApplication) -> Bool {
       // Override point for customization after application launch.you’re
       NSApplication.shared.registerForRemoteNotifications()
       return true
    }

    func application(_ application: NSApplication,
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

    func application(_ application: NSApplication,
                didFailToRegisterForRemoteNotificationsWithError
                    error: Error) {
       // Try again later.
    }
}
