//
//  Platformify.swift
//  lido
//
//  Created by Everett Wilber on 7/1/22.
//

import SwiftUI

struct MacOS: View {
    @EnvironmentObject var appData: AppData
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
                        Text("Hello")
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
                        Text("Hello")
                    } label: {
                        Label(
                            "Profile",
                            systemImage: "person.crop.circle"
                        )
                    }
                }
                .listStyle(.sidebar)
            }
            .toolbar {
                ToolbarItem(content: {
                    Label("Add",systemImage: "plus")
                })
            }
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
