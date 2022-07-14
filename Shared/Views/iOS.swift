//
//  iOS.swift
//  lido
//
//  Created by Everett Wilber on 7/1/22.
//

import SwiftUI

struct iOS: View {
    @EnvironmentObject var appData: AppData
    @State var creatingMember: Bool = false
    var body: some View {
        Group {
            TabView {
                Text("Hello")
                    .tabItem {
                        Label(
                            "Stats",
                            systemImage: "chart.line.uptrend.xyaxis"
                        )
                    }
                NavigationView {
                    List {
                        CarpoolView()
                    }
                }
                    .tabItem {
                        Label(
                            "Carpool",
                            systemImage: "car.2"
                        )
                    }
                Text("Hello")
                    .tabItem {
                        Label(
                            "Now",
                            systemImage: "figure.walk.circle"
                        )
                    }
                NavigationView{
                    List {
                        BrowseView()
                    }
                    .toolbar {
                        ToolbarItem(id: "Add", placement: .primaryAction) {
                            Button {
                                creatingMember = true
                            } label: {
                                Label("Add", systemImage: "plus")
                            }
                            .buttonStyle(.plain)
                        }
                        ToolbarItem(id: "Reload", placement: .navigation) {
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
                            .buttonStyle(.plain)
                        }
                    }
                }
                .sheet(isPresented: $creatingMember, content: {
                    NewMemberView(submit: {creatingMember  = false})
                })
                .tabItem {
                    Label(
                        "Browse",
                        systemImage: "square.grid.2x2.fill"
                    )
                }
                ProfileView()
                    .tabItem {
                        Label(
                            "Profile",
                            systemImage: "person.crop.circle"
                        )
                    }
            }
            .tabViewStyle(.automatic)
        }
        .sheet(isPresented: $appData.loggedOut, content: {
            LoginView()
                .environmentObject(appData)
                .interactiveDismissDisabled(true)
        })
    }
}

struct iOS_Previews: PreviewProvider {
    static var previews: some View {
        iOS()
    }
}
