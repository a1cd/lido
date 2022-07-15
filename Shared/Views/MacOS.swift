//
//  Platformify.swift
//  lido
//
//  Created by Everett Wilber on 7/1/22.
//

import SwiftUI

struct MacOS: View {
    @EnvironmentObject var appData: AppData
    
    @State var creatingMember: Bool = false
    var body: some View {
        Group {
            NavigationView {
                List {
                    NavigationLink {
                        Text("Hello")
                    } label: {
                        Label(
                            "Stats",
                            systemImage: "chart.line.uptrend.xyaxis"
                        )
                    }
                    NavigationLink {
                        CarpoolView()
                    } label: {
                        Label(
                            "Carpool",
                            systemImage: "car.2"
                        )
                    }
                    NavigationLink {
                        Text("Hello")
                    } label: {
                        Label(
                            "Now",
                            systemImage: "figure.walk.circle"
                        )
                    }
                    Section("Browse") {
                        BrowseView()
                            .padding(.leading)
                        
                    }
                    NavigationLink {
                        ProfileView()
                            .navigationTitle("Profile")
                    } label: {
                        Label(
                            "Profile",
                            systemImage: "person.crop.circle"
                        )
                    }
                }
                .listStyle(.sidebar)
            }
            .toolbar(id: "MacOSToolbar") {
                ToolbarItem(id: "reload", placement: .navigation) {
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
            }
            .sheet(isPresented: $creatingMember, content: {
                NewMemberView(submit: {creatingMember  = false})
            })
        }
        .sheet(isPresented: $appData.loggedOut, content: {
            LoginView()
                .environmentObject(appData)
        })
    }
}

struct MacOS_Previews: PreviewProvider {
    static var previews: some View {
        MacOS()
    }
}
