//
//  lidoApp.swift
//  Shared
//
//  Created by Everett Wilber on 6/8/22.
//

import SwiftUI

@main
struct lidoApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var appData = AppData()
    #if os(macOS)
    @NSApplicationDelegateAdaptor private var appDelegate: LidoAppDelegate
    #else
    @UIApplicationDelegateAdaptor private var appDelegate: LidoAppDelegate
    #endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appData)
                .environmentObject(appDelegate)
        }
    }
}
