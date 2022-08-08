//
//  MemberNameView.swift
//  lido
//
//  Created by Everett Wilber on 7/7/22.
//

import SwiftUI

struct MemberNameView: View {
    @Binding var member: Member
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: member.systemImage)
                .font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)
                .accessibilityHidden(true)
                .animation(.easeInOut, value: member)
                .transition(.opacity)
            VStack {
                Text(member.personName.formatted(.name(style: .medium)))
                    .animation(.easeInOut, value: member)
                    .transition(.opacity)
                HStack {
                    member.status.label.labelStyle(.iconOnly)
                    member.location.label.labelStyle(.iconOnly)
                }
                .animation(.easeInOut, value: member)
                .transition(.opacity)
            }
        }
    }
}

struct MemberNameView_Previews: PreviewProvider {
    static var previews: some View {
        MemberNameView(member: .constant(Member.test))
    }
}
