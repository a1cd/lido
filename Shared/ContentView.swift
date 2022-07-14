//
//  ContentView.swift
//  Shared
//
//  Created by Everett Wilber on 6/8/22.
//

import SwiftUI
import CoreData
import UserNotifications

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State var creatingMember = false
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var appDelegate: LidoAppDelegate
    
    var body: some View {
        Group {
            Group {
#if os(iOS)
                iOS()
#elseif os(macOS)
                MacOS()
#else
                EmptyView()
#endif
            }
        }
        .onChange(of: appDelegate.deviceNotificationToken, perform: {token in
            if let token = token {
                Task {
                    await appData.setNotificationToken(token: token)
                }
            } else {
                appData.notificationTokenState = .noToken
            }
        })
        .task {
            #if os(macOS)
            NSApplication.shared.registerForRemoteNotifications()
            #else
            UIApplication.shared.registerForRemoteNotifications()
            #endif
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                
                if let error = error {
                    print(error)
                }
                print(granted)
                // Enable or disable features based on the authorization.
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
