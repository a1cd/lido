//
//  MemberView.swift
//  lido
//
//  Created by Everett Wilber on 6/21/22.
//

import SwiftUI

struct MemberView: View {
    @EnvironmentObject var appData: AppData
    @Binding var member: Member
    @State var location: Member.Location = .unknown
    @State var status: Member.Status = .unknown
    var body: some View {
        VStack {
            MemberNameView(member: $member)
            HStack {
                Text("Age: ")
                Text("\(member.age ?? 0)")
            }
            Text("\(member.personName.formatted(.name(style: .short))) was last reported \((member.status ?? Member.Status.unknown).description) \((member.location ?? Member.Location.unknown).description).")
            HStack {
                Picker(selection: $status, label: Text("Status").hidden()) {
                    ForEach(Member.Status.allCases) {status in
                        Label(status.description, systemImage: status.symbol)
                    }
                }
                Picker(selection: $location, label: Text("Location").hidden()) {
                    ForEach(Member.Location.allCases) {location in
                        Label(location.description, systemImage: location.symbol)
                    }
                }
            }
        }
        .task {
            location = member.location ?? .unknown
            status = member.status ?? .unknown
        }
        .onChange(of: location, perform: {_ in
            Task {
                try await appData.setStatus(member._id, status, location)
            }
        })
        .onChange(of: status, perform: {_ in
            Task {
                try await appData.setStatus(member._id, status, location)
            }
        })
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
