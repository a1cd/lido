//
//  LoginView.swift
//  lido
//
//  Created by Everett Wilber on 6/25/22.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appData: AppData
    @State var username: String = ""
    @State var password: String = ""
    @Binding var loggedOut: Bool
    var body: some View {
        VStack {
            Text("Login")
                .font(.largeTitle)
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: {
                appData.username = username
                appData.password = password
                Task {
                    await appData.getSessionToken()
                    loggedOut = false
                    await appData.getMembers()
                    await appData.setupWebsocket()
                }
            }, label: {Text("Login")})
            .buttonStyle(.borderedProminent)
        }
        .padding(.all)
        .scaledToFill()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(loggedOut: .constant(true))
    }
}
