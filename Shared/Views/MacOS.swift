//
//  Platformify.swift
//  lido
//
//  Created by Everett Wilber on 7/1/22.
//

import SwiftUI

struct MacOS: View {
    @EnvironmentObject var appData: AppData
    
    @Binding var expansionState: ExpansionState
    
    @State var creatingMember: Bool = false
    
    var body: some View {
        Group {
            NavigationView {
                VStack {
                    List {
                        NavigationLink {
                            Text("Hello")
                        } label: {
                            Label(
                                "statsTabLabel",
                                systemImage: "chart.line.uptrend.xyaxis"
                            )
                        }
                        NavigationLink {
                            CarpoolView()
                        } label: {
                            Label(
                                "carpoolTabLabel",
                                systemImage: "car.2"
                            )
                        }
                        NavigationLink {
                            Text("Hello")
                        } label: {
                            Label(
                                "nowTabLabel",
                                systemImage: "figure.walk.circle"
                            )
                        }
                        DisclosureGroup(isExpanded: $expansionState[expansionState.browse]) {
                            BrowseView()
                                .padding(.leading)
                            
                        } label: {
                            Label("browseTabLabel", systemImage: "square.grid.2x2")
                        }
                        NavigationLink {
                            ProfileView()
                                .navigationTitle("Profile")
                        } label: {
                            Label(
                                "profileTabLabel",
                                systemImage: "person.crop.circle"
                            )
                        }
                    }
                    .listStyle(.sidebar)
                }
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
                        Label("reload", systemImage: "arrow.clockwise")
                    }

                }
            }
            .sheet(isPresented: $creatingMember, content: {
                NewMemberView(submit: {creatingMember  = false})
            })
            .sheet(isPresented: $appData.loggedOut, content: {
                LoginView()
                    .environmentObject(appData)
            })
        }
    }
}

struct MacOS_Previews: PreviewProvider {
    static var previews: some View {
        MacOS(expansionState: .constant(ExpansionState()))
    }
}
