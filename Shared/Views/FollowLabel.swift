//
//  FollowLabel.swift
//  lido
//
//  Created by Everett Wilber on 7/21/22.
//

import SwiftUI

struct FollowLabel: View {
    
    enum FollowLabelType {
        case none
        case some
        case all
        case disabled
    }
    
    @Binding var followLabelStatus: FollowLabelType
    
    @State private var hovered = false
    
    var action: () -> Void
    
    var followLabel: some View {
        print("reunt")
        return Group {
            if followLabelStatus == .disabled {
                Label("follow", systemImage: "star")
                    .disabled(true)
            } else if followLabelStatus == .all {
                if hovered {
                    Label("unfollow", systemImage: "star.slash.fill")
                } else {
                    Label("unfollow", systemImage: "star.fill")
                }
            } else if followLabelStatus == .none {
                Label("follow", systemImage: "star")
            } else if followLabelStatus == .some {
                Label("follow", systemImage: "star.leadinghalf.filled")
            }
        }
    }
    var body: some View {
        Button(action: action, label: {followLabel})
            .disabled(followLabelStatus == .disabled)
            .onChange(of: followLabelStatus, perform: { i in
                print("followLabelStatus now is: ")
                print(followLabelStatus)
            })
            .onHover(perform: { isHovered in
                hovered = isHovered
            })
    }
}

struct FollowLabel_Previews: PreviewProvider {
    static var previews: some View {
        FollowLabel(followLabelStatus: .constant(.disabled), action: {})
    }
}
