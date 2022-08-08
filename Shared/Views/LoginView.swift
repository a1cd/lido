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
    @State var status = Status.login
    enum Status {
        case login
        case signUp
    }
    
    var login: some View {
        Form(content: {
            Text("login")
                .font(.largeTitle)
            TextField("username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocorrectionDisabled(true)
                .textContentType(.username)
                .submitLabel(SubmitLabel.next)
#if os(iOS)
                .autocapitalization(.none)
#endif
            SecureField("password", text: $password)
                .submitLabel(SubmitLabel.done)
                .autocorrectionDisabled(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.password)
                .frame(idealWidth: 250.0)
            Button(action: {
                submit(true)
            }, label: {Text("login")})
            .buttonStyle(.borderedProminent)
        })
    }
    
    @State var signupData = SignupData()
    var signup: some View {
        Form(content: {
            Text("signup")
                .font(.title)
            TextField("username", text: $signupData.username)
            TextField("password", text: $signupData.password)
            TextField("fullName", value: $signupData.fullName, format: .name(style: .long))
            TextField("age", value: $signupData.age, format: .number)
            Toggle(isOn: $signupData.isStaff, label: {Label("isStaffToggleLabel", systemImage: "building.2.crop.circle")})
        })
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                if (status == .login) {
                    login
                    
                } else {
                    signup
                }
                Button {
                    switch status {
                    case .login:
                        status = .signUp
                    case .signUp:
                        status = .login
                    }
                } label: {
                    switch status {
                    case .signUp:
                        Label("login", systemImage: "ellipsis.rectangle")
                    case .login:
                        Label("signup", systemImage: "person.crop.circle.badge.plus")
                    }
                }
                #if os(macOS)
                .buttonStyle(.link)
                #else
                .buttonStyle(.borderless)
                #endif
                .padding()
            }
            if progress != nil {
                ProgressView(value: self.progress)
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .disabled(progress != nil)
        .padding(.all)
        .scaledToFill()
        .alert(isPresented: $errorOccured, content: {
            Alert(
                title: Text("error"),
                message: Text(errorDescription ?? ""),
                dismissButton: .cancel(
                    Text("dismiss"),
                    action: {reset()}
                )
            )
        })
        .scaledToFit()
        
    }
}
struct SignupData:  Identifiable {
    @State var id = UUID()
    @State var username: String = ""
    @State var password: String = ""
    @State var fullName: PersonNameComponents = PersonNameComponents()
    @State var age: Int = 0
    @State var isStaff: Bool = true
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
