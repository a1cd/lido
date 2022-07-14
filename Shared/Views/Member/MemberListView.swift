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
    
    @State var search: String = ""
    var body: some View {
//        NavigationView {
            List {
                ForEach($appData.members.list.filter({ member in
                    return (search=="") ? true : (member.wrappedValue.mediumName).localizedCaseInsensitiveContains(search)
                }), content: {member in
                    NavigationLink(destination: {
                        MemberView(member: member)
                            .navigationTitle(member.wrappedValue.mediumName)
                    }) {
                        MemberLabel(member: member.wrappedValue)
                    }
                    #if os(macOS)
                    .onDeleteCommand {
                        Task {
                            try await appData.deleteMember(member.wrappedValue._id)
                        }
                    }
                    #endif
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
                .onDelete { indexSet in
                    indexSet.map { i in
                        return appData.members.list[i]._id
                    }.forEach { _id in
                        Task {
                            try await appData.deleteMember(_id)
                        }
                    }
                }
//            }
//            .sheet(isPresented: $addingMember, content: {
//                NewMemberView(submit: {
//                    addingMember = false
//                })
//            })
        }
        .searchable(text: $search) {
            ForEach(appData.members.list.filter({ member in
                return member.mediumName.localizedCaseInsensitiveContains(search)
            })) { member in
                Text(member.mediumName)
                    .searchCompletion(member.mediumName)
            }
        }
    }
}

struct MemberListView_Previews: PreviewProvider {
    static var previews: some View {
        MemberListView()
    }
}
