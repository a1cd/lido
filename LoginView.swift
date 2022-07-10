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
    @State var errorDescription: String?
    @State var errorOccured: Bool = false
    @State var progress: Double? = nil
    func reset(_ all: Bool = false) {
        errorDescription = nil
        errorOccured = false
        progress = nil
        if all {
            username = ""
            password = ""
        }
    }
    func submit(_ button: Bool) {
        var isMacOS = false
        if #available(macOS 8, *) {
            isMacOS = true
        }
        
        if button || isMacOS {
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
                    appData.loggedOut = false
                } catch AppData.CommunicationError.unauthenticated {
                    appData.loggedOut = true
                } catch let error as AppData.CommunicationError {
                    errorDescription = error.description
                    errorOccured = true
                } catch {
                    errorOccured = true
                    self.errorDescription = error.localizedDescription
                }
                
            }
        }
    }
    var body: some View {
        ZStack {
            VStack {
                Text("Login")
                    .font(.largeTitle)
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocorrectionDisabled(true)
                #if os(iOS)
                    .autocapitalization(.none)
                #endif
                SecureField("Password", text: $password) {
                    submit(false)
                }
                    .submitLabel(SubmitLabel.return)
                    .autocorrectionDisabled(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    submit(true)
                }, label: {Text("Login")})
                .buttonStyle(.borderedProminent)
            }
            .onAppear(perform: {
                print(String.init(data: try! JSONEncoder().encode(Member.Location.unknown), encoding: .utf8)!)
                print("marker")
            })
            .disabled(progress != nil)
            .padding(.all)
            .scaledToFill()
            .alert(isPresented: $errorOccured, content: {
                Alert(
                    title: Text("Error"),
                    message: Text(errorDescription ?? ""),
                    dismissButton: .cancel(
                        Text("Dismiss"),
                        action: {
                            errorOccured = false
                            reset()
                        }
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
        LoginView()
    }
}
