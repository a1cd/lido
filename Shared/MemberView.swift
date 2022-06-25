//
//  MemberView.swift
//  lido
//
//  Created by Everett Wilber on 6/21/22.
//

import SwiftUI

struct MemberView: View {
    @EnvironmentObject var appData: AppData
    @State var member: Member
    var body: some View {
        VStack{
            HStack {
                Text(member.first ?? "")
                Text(member.last ?? "")
            }
            HStack {
                Text("Age: ")
                Text("\(member.age ?? 0)")
            }
        }
    }
}
//
//struct MemberView_Previews: PreviewProvider {
//    static var previews: some View {
//        MemberView(member: Member(
//                _id: "",
//                dateAdded: nil,
//                dateChanged: nil,
//                first: "Joe",
//                last: "Biden",
//                age: 16,
//                aftercare: false,
//                isCounsoleor: true
//            )))
//        
//    }
//}
