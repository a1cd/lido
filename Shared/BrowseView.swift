//
//  MembersView.swift
//  lido
//
//  Created by Everett Wilber on 6/25/22.
//

import SwiftUI

struct BrowseView: View {
    
    var body: some View {
            NavigationLink(
                destination: {
                    MemberListView()
                },
                label: {
                    Label("Members", systemImage: "person.3.sequence.fill")
                        .symbolRenderingMode(.hierarchical)
                }
            )
            .navigationTitle("Members")
            NavigationLink (destination: {
                Text("Households")
            },
            label: {
                Label("Households", systemImage: "house.fill")
                    .symbolRenderingMode(.multicolor)
            })
            .navigationTitle("Households")
            NavigationLink (destination: {
                Text("Rooms")
            },
            label: {
                Label("Rooms", systemImage: "person.2.crop.square.stack")
                    .symbolRenderingMode(.multicolor)
            })
            .navigationTitle("Rooms")
    }
}

struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView()
    }
}
