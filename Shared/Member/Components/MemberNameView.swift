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
            VStack {
                Text(member.personName.formatted(.name(style: .medium)))
                HStack {
                    Image(systemName: member.status?.symbol ?? Member.Location.unknown.symbol)
                    Image(systemName: member.location?.symbol ?? Member.Location.unknown.symbol)
                }
            }
        }
    }
}

struct MemberNameView_Previews: PreviewProvider {
    static var previews: some View {
        MemberNameView(member: .constant(Member.test))
    }
}
