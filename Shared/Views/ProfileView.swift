//
//  ProfileView.swift
//  lido
//
//  Created by Everett Wilber on 7/11/22.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appData: AppData
    var body: some View {
        VStack {
            Text(appData.username ?? "24wilber")
            Button() {
                appData.token = nil
                appData.loggedOut = true
            } label: {
                Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    var appData = AppData()
    static var previews: some View {
        ProfileView()
    }
}
