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
    @State var error: String?
    @State var errorOccured: Bool = false
    @State var progress: Double? = nil
    var body: some View {
        ZStack {
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
                        do {
                            progress = 0.0
                            try await appData.getSessionToken()
                            progress = 0.333
                            try await appData.getMembers()
                            progress = 0.666
                            await appData.setupWebsocket()
                            progress = 1.0
                            loggedOut = false
                        } catch {
                            errorOccured = true
                            self.error = error.localizedDescription
                        }
                        
                    }
                }, label: {Text("Login")})
                .buttonStyle(.borderedProminent)
                
            }
            .padding(.all)
            .scaledToFill()
            .alert(isPresented: $errorOccured, content: {
                Alert(
                    title: Text("Error"),
                    message: Text(error ?? ""),
                    dismissButton: .cancel(
                        Text("Dismiss"),
                        action: {errorOccured = false}
                    )
                )
            })
            if progress != nil {
                ProgressView(value: self.progress)
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(loggedOut: .constant(true))
    }
}
