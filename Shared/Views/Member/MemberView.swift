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
    @State var changes: Int = 2
    var body: some View {
        VStack {
            MemberNameView(member: $member)
            HStack {
                Text("Age: ")
                Text("\(member.age )")
            }
            Text("\(member.personName.formatted(.name(style: .short))) was last reported \((member.status ).description) \((member.location ).description).")
                .animation(.easeInOut, value: location)
                .animation(.easeInOut, value: member)
                .animation(.easeInOut, value: status)
                .transition(.opacity)
            HStack {
                Picker(selection: $status, label: Text("Status").hidden()) {
                    ForEach(Member.Status.allCases) {status in
                        Label(status.description, systemImage: status.symbol)
                    }
                }
                .animation(.easeInOut, value: status)
                .transition(.opacity)
                Picker(selection: $location, label: Text("Location").hidden()) {
                    ForEach(Member.Location.allCases) {location in
                        Label(location.description, systemImage: location.symbol)
                    }
                }
                .animation(.easeInOut, value: location)
                .transition(.opacity)
            }
        }
        .userToolbar(.constant(member.id))
        .task {
            location = member.location
            status = member.status
        }
        .onChange(of: member, perform: {_ in
            if location != member.location {
                changes += 1
                withAnimation {
                    location = member.location
                }
            }
            if status != member.status {
                changes += 1
                withAnimation {
                    status = member.status
                }
            }
        })
        .onChange(of: location, perform: {_ in
            if changes<=0 {
                Task {
                    try await appData.setStatus(member._id, status, location)
                }
            } else {
                print("location")
                print(changes)
                changes -= 1
            }
        })
        .onChange(of: status, perform: {_ in
            if changes<=0 {
                Task {
                    try await appData.setStatus(member._id, status, location)
                }
            } else {
                print("status")
                print(changes)
                changes -= 1
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
