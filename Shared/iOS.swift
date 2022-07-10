//
//  iOS.swift
//  lido
//
//  Created by Everett Wilber on 7/1/22.
//

import SwiftUI

struct iOS: View {
    @EnvironmentObject var appData: AppData
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
                Text("Hello")
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
                }
                    .tabItem {
                        Label(
                            "Browse",
                            systemImage: "square.grid.2x2.fill"
                        )
                    }
                Text("Hello")
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
