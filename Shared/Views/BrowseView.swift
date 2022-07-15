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
                    #if os(macOS)
                    MemberTableView()
                        .navigationTitle("Members")
                    #else
                    MemberListView()
                        .navigationTitle("Members")
                    #endif
                },
                label: {
                    Label("Members", systemImage: "person.3.sequence.fill")
                        .symbolRenderingMode(.hierarchical)
                }
            )
            
            NavigationLink (destination: {
                Text("Households")
                    .navigationTitle("Households")
            },
            label: {
                Label("Households", systemImage: "house.fill")
                    .symbolRenderingMode(.multicolor)
            })
            
            NavigationLink (destination: {
                Text("Rooms")
                    .navigationTitle("Rooms")
            },
            label: {
                Label("Rooms", systemImage: "person.2.crop.square.stack")
                    .symbolRenderingMode(.multicolor)
            })
    }
}

struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView()
    }
}
