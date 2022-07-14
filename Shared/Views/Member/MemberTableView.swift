//
//  MemberTableView.swift
//  lido (macOS)
//
//  Created by Everett Wilber on 7/14/22.
//

import SwiftUI

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
    @State private var selection = Set<Member.ID>()

    @State var sortOrder: [KeyPathComparator<Member>] = [
        .init(\.last, order: SortOrder.forward)
    ]
    
    var table: some View {
        Table(appData.members.list, selection: $selection, sortOrder: $sortOrder) {
            TableColumn("First", value: \.first)
            TableColumn("Last", value: \.last)
            TableColumn("Location", value: \.age) { member in
                Text(member.age)
            }
            TableColumn("Status", value: \.status) { member in
                Label(member.status.description, systemImage: member.status.symbol)
            }
            TableColumn("Location", value: \.location) { member in
                Label(member.location.description, systemImage: member.location.symbol)
            }
        }
    }
    
    var body: some View {
        table
            .navigationTitle("Members")
    }
}

struct MemberTableView_Previews: PreviewProvider {
    static var previews: some View {
        MemberTableView()
    }
}
