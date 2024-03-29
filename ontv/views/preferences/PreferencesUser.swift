//
//  Preferences.swift
//  Preferences
//
//  Created by Alex on 21/09/2021.
//

import CoreStore
import Defaults
import Settings
import SwiftUI

extension PreferencesView {
  struct User: View {

    struct UserInfoView: View {

      @ObservedObject var api = API.Adapter

      var body: some View {
        HStack(alignment: .center, spacing: 5) {
          VStack(alignment: .trailing) {
            Text("UserName")
            Text("Status")
            Text("Active Conn")
            Text("Max conn")
            Text("Expires")
          }.textCase(.lowercase)
            .font(Theme.Font.Preferences.userLabel)
            .frame(maxHeight: .infinity)
          VStack(alignment: .leading) {
            Text(api.user?.username ?? "")
            Text(api.user?.status ?? "")
            Text(api.user?.active_cons ?? "")
            Text(api.user?.max_connections ?? "")
            Text(api.expires)
          }.frame(maxHeight: .infinity)
            .font(Theme.Font.Preferences.userValue)
        }.fixedSize(horizontal: false, vertical: true)
      }

    }

    @ObservedObject var api = API.Adapter
    @Default(.server_host) var server_host
    @Default(.server_protocol) var server_protocol

    @Default(.username) var username
    @Default(.password) var password

    @Default(.useProxy) var use_proxy

    private let contentWidth: Double = 450.0
    private let padding: Double = 15

    func login() {
      Task.init {
        await api.doLogin(username: username, password: password)
      }
    }

    var body: some View {
      Settings.Container(contentWidth: contentWidth) {
        Settings.Section(title: "Server Info") {
          VStack(spacing: self.padding) {
            TextField("Host", text: $server_host)
          }.disabled(api.state == .loading)
          VStack(spacing: self.padding) {
            TextField("Protocol", text: $server_protocol)
          }.disabled(api.state == .loading)
        }
        Settings.Section(title: "Credentials") {
          VStack(spacing: self.padding) {
            TextField("Username", text: $username)
          }.disabled(api.state == .loading)
          VStack(spacing: self.padding) {
            SecureField("Password", text: $password)
          }.disabled(api.state == .loading)
        }
        Settings.Section(title: "User info") {
          VStack(spacing: self.padding) {
            UserInfoView()
          }
        }
        Settings.Section(title: "Player") {
          VStack(spacing: self.padding) {
            HStack {
              Toggle(isOn: $use_proxy) {
                Text("Use HTTPS Proxy")
                  .frame(maxWidth: 180, alignment: .leading)
              }
            }
          }
        }
      }
      HStack {
        Button(action: { login() }) {
          Text(api.state == .loading ? "Wait..." : "Save")
        }.disabled(api.state == .loading)
      }.onAppear(perform: {
        Task.init {
          do {
            try await api.updateUser()
          }
          catch {
          }
        }
      }).padding()
    }
  }

}
