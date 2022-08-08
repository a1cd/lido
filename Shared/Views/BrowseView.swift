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
                        .navigationTitle("members")
                },
                label: {
                    Label("members", systemImage: "person.3.sequence.fill")
                        .symbolRenderingMode(.hierarchical)
                }
            )
            
            NavigationLink (destination: {
                Text("households")
                    .navigationTitle("households")
            },
            label: {
                Label("households", systemImage: "house.fill")
                    .symbolRenderingMode(.multicolor)
            })
            
            NavigationLink (destination: {
                Text("rooms")
                    .navigationTitle("rooms")
            },
            label: {
                Label("rooms", systemImage: "person.2.crop.square.stack")
                    .symbolRenderingMode(.multicolor)
            })
    }
}

struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView()
    }
}
