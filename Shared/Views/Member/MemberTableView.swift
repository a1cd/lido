//
//  MemberTableView.swift
//  lido (macOS)
//
//  Created by Everett Wilber on 7/14/22.
//

import SwiftUI

@available(iOS 16.0, macOS 8.0, macCatalyst 16.0, *)
struct MemberTableView: View {
    enum ViewMode: String, CaseIterable, Identifiable {
        var id: Self { self }
        case table
        case gallery
    }

    @EnvironmentObject var appData: AppData
//    @Binding var gardenId: Garden.ID?
    @State var searchText: String = ""
    @SceneStorage("viewMode") private var mode: ViewMode = .table
    @State private var userSelection = Set<Member.ID>()
    
    @State var sortOrder: [KeyPathComparator<Member>] = [
        .init(\.first, order: SortOrder.forward)
    ]
    
    var members: [Member] {
        return appData.members.list
            .filter {
                searchText.isEmpty ? true : $0.mediumName.localizedCaseInsensitiveContains(searchText)
            }
            .sorted(using: sortOrder)
    }
    
    var table: some View {
        Table(members, selection: $userSelection, sortOrder: $sortOrder) {
            TableColumn("First", value: \.first)
            TableColumn("Last", value: \.last)
            TableColumn("Age", value: \.age.description)
            TableColumn("Status", value: \.status) {
                Label($0.status.description, systemImage: $0.status.symbol)
            }
            TableColumn("Location", value: \.location) {
                Label($0.location.description, systemImage: $0.location.symbol)
            }

            TableColumn("follow", content: {member in
                if let memberId = appData.session?.memberId {
                    if (member.subscribers.contains(memberId)) {
                        Label("Subscribed", systemImage: "star.fill")
                            .labelStyle(.iconOnly)
                    } else {
                        Label("Not Subscribed", systemImage: "star")
                            .labelStyle(.iconOnly)
                    }
                } else {
                    Label("Subscription not Available", systemImage: "star")
                        .disabled(true)
                        .redacted(reason: SwiftUI.RedactionReasons.placeholder)
                        .labelStyle(.iconOnly)
                }
            })
        }
    }
    
    var body: some View {
        table
            .userToolbar($userSelection)
            .navigationTitle("memberTableNavTitle")
    }
}



struct MemberTableView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, macOS 8.0, macCatalyst 16.0, *) {
            MemberTableView().table
                .environmentObject(AppData.preview)
        } else {
            EmptyView()
        }
    }
}
