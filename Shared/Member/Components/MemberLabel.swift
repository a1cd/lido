//
//  MemberLabel.swift
//  lido
//
//  Created by Everett Wilber on 6/30/22.
//

import SwiftUI

struct MemberLabel: View {
    @EnvironmentObject var appData: AppData
    @State var member: Member
    var body: some View {
        Label(
            member.personName.formatted(.name(style: .short)),
            systemImage: member.systemImage
        )
    }
}

struct MemberLabel_Previews: PreviewProvider {
    static var previews: some View {
        MemberLabel(member: Member(_id: "", first: "Everett", last: "Wilber", isCounsoleor: true))
        MemberLabel(member: Member(_id: "", first: "Mac", last: "Kantz", isCounsoleor: false))
        MemberLabel(member: Member(_id: "", first: "Madline", last: "Gottfried", isCounsoleor: nil))
    }
}
