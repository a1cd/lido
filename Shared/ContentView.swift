//
//  ContentView.swift
//  Shared
//
//  Created by Everett Wilber on 6/8/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @StateObject var appData = AppData()
    @State var creatingMember = false
    
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
            .toolbar {
                Button {
                    creatingMember = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
                Button {
                    Task {
                        do {
                            try await appData.reload()
                        } catch let error as AppData.CommunicationError {
                            print(error)
                        }
                    }
                } label: {
                    Label("Reload", systemImage: "arrow.clockwise")
                }

            }
            .sheet(isPresented: $creatingMember, content: {
                NewMemberView(submit: {creatingMember  = false})
            })
        }
        .environmentObject(appData)
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
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
