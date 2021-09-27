//
//  Preferences.swift
//  Preferences
//
//  Created by Alex on 21/09/2021.
//

import CoreStore
import Defaults
import Preferences
import SwiftUI

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

struct PreferencesView: View {
  @ObservedObject var api = API.Adapter
  @Default(.server_host) var server_host
  @Default(.server_port) var server_port
  @Default(.server_protocol) var server_protocol
  @Default(.server_secure_port) var server_secure_port

  @Default(.username) var username
  @Default(.password) var password

  private let contentWidth: Double = 450.0
  private let padding: Double = 15

  func login() {
    Task.init {
      await api.login(username: username, password: password)

    }
  }

  var body: some View {
    Preferences.Container(contentWidth: contentWidth) {
      Preferences.Section(title: "Server Info") {
        VStack(spacing: self.padding) {
          TextField("Host", text: $server_host)
        }.disabled(api.state == .loading)
        VStack(spacing: self.padding) {
          TextField("Port", text: $server_port)
        }.disabled(api.state == .loading)
        VStack(spacing: self.padding) {
          TextField("Protocol", text: $server_protocol)
        }.disabled(api.state == .loading)
        VStack(spacing: self.padding) {
          TextField("Secure Port", text: $server_secure_port)
        }.disabled(api.state == .loading)
      }
      Preferences.Section(title: "Credentials") {
        VStack(spacing: self.padding) {
          TextField("Username", text: $username)
        }.disabled(api.state == .loading)
        VStack(spacing: self.padding) {
          SecureField("Password", text: $password)
        }.disabled(api.state == .loading)
      }
      Preferences.Section(title: "User info") {
        VStack(spacing: self.padding) {
          UserInfoView()
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
