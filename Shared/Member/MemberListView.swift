//
//  MemberListView.swift
//  lido
//
//  Created by Everett Wilber on 6/29/22.
//

import SwiftUI

struct MemberListView: View {
    @EnvironmentObject var appData: AppData
    @Environment(\.refresh) private var refresh
    @State var addingMember: Bool = false
    var body: some View {
        NavigationView {
            List {
                ForEach($appData.members.list, content: {member in
                    NavigationLink(destination: {
                        MemberView(member: member)
                    }) {
                        MemberLabel(member: member.wrappedValue)
                    }
                    .onDeleteCommand {
                        Task {
                            try await appData.deleteMember(member.wrappedValue._id)
                        }
                    }
                    .contextMenu(ContextMenu(menuItems: {
                        Button {
                            Task {
                                try await appData.deleteMember(member.wrappedValue._id)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            Task {
                                print("refresh?")
                                if (refresh == nil) {
                                    print("refresh is nil")
                                }
                                await refresh?()
                            }
                        } label: {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                    }))
                })
            }
            .refreshable {
                do {
                    try await appData.getMembers()
                } catch {
                    print("error ")
                }
            }
            .sheet(isPresented: $addingMember, content: {
                NewMemberView(submit: {
                    addingMember = false
                })
            })
        }
    }
}

struct MemberListView_Previews: PreviewProvider {
    static var previews: some View {
        MemberListView()
    }
}
