//
//  NewMemberView.swift
//  lido
//
//  Created by Everett Wilber on 6/21/22.
//

import SwiftUI

struct NewMemberView: View {
    @EnvironmentObject var appData: AppData
    @State var name = PersonNameComponents()
    @State var age = 0
    @State var aftercare = false
    @State var counsoleor = false
    @State var submit: () -> Void
    @State var alert: Bool = false
    @State var alertText: String = ""
    
    var number: NumberFormatter {
        let number = NumberFormatter()
        number.allowsFloats = false
        number.maximum = 99
        number.minimum = 0
        return number
    }
    var body: some View {
        GroupBox {
            Form {
                TextField(
                    "",
                    value: $name,
                    format: .name(style: .medium),
                    prompt: Text("fullName")
                )
                .textFieldStyle(PlainTextFieldStyle())
                .font(.title)
                Stepper(value: $age, in: 0...100) {
                    Text("Age: \(age)")
                }
                Toggle("aftercare", isOn: $aftercare)
                Toggle("counsoleor", isOn: $counsoleor)
                Button(action: {
                    Task {
                        do {
                            try await self.appData.addMember(
                                member: AppData.NewMember(
                                    first: name.givenName?.capitalized,
                                    middleInitial: name.middleName?.first?.uppercased(),
                                    last: name.familyName?.capitalized,
                                    age: age,
                                    aftercare: aftercare,
                                    isCounsoleor: counsoleor
                                )
                            )
                        } catch {
                            
                            alert = true
                            alertText = error.localizedDescription
                        }
                        submit()
                    }
                }, label: {
                    Text("Submit")
                })
            }
        }
        .padding()
        .alert(isPresented: self.$alert, content: {
            Alert(title: Text("An Error Occured"),message: Text(alertText))
        })
    }
}

struct NewMemberView_Previews: PreviewProvider {
    static var previews: some View {
        NewMemberView(submit: {})
    }
}
