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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
