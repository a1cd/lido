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
	@State private var creatingUser = false
    @State private var loggedOut = true
    
    var body: some View {
        NavigationView {
            List {
                ForEach(appData.members.list,id: \._id) { (member) in
                    NavigationLink {
                        MemberView(member: member)
                    } label: {
                        Text("\(member.first ?? "") \(member.last ?? "")")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: {
                        Task {
                            await appData.logout()
                        }
                    }, label: {
                        Text("User")
                    })
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
        .sheet(isPresented: $loggedOut, content: {
            LoginView(loggedOut: $loggedOut)
        })
        .sheet(isPresented: $creatingUser) {
            NewMemberView(submit: {creatingUser.toggle()})
        }
        .environmentObject(appData)
    }

    private func addItem() {
        withAnimation {
            self.creatingUser = true
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            print(offsets)
            offsets.forEach( {i in
                print(i)
                Task {
                    do {
                        try await appData.deleteMember(i)
                    } catch {
                        print("deleted problem")
                        print(error)
                        print(#filePath+" "+"\(#line)")
                    }
                }
            })
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
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
