//
//  Api.swift
//  Api
//
//  Created by Alex on 27/09/2021.
//

import AppKit
import Combine
import CoreStore
import Defaults
import Foundation
import ObjectiveC

extension Defaults.Keys {
  static let userinfo = Key<API.UserInfo>("userinfo", default: .init(username: "", password: ""))
  static let serverinfo = Key<API.ServerInfo>(
    "serverinfo",
    default: .init(url: "", port: "", server_protocol: "")
  )
}

enum API {

  enum State {
    case starting, started, error, loading, loggedin, loaded
  }

  enum FetchType {
    case streams, schedule, epg, livescore, sports
  }

  enum LoadingItem: String {
    case epg = "Loading EPG"
    case schedule = "Loading TheSportsDb"
    case stream = "Loading streams"
    case category = "Loading categories"
    case loaded = "Done"
    case livescore = "Loading livescores"
    case sports = "Loading Sports"
  }

  static let Adapter = ApiAdapter()

  class ApiAdapter: NSObject, ObservableObject {
    @Published var error: API.Exception? = nil
    @Published var state: API.State = .loading
    @Published var loading: API.LoadingItem = .loaded
    @Published var epgState: ProviderState = .notavail
    @Published var user: UserInfo? = nil
    @Published var expires: String = ""

    var server_info: ServerInfo = ServerInfo(
      url: Defaults[.server_host],
      port: Defaults[.server_port],
      https_port: Defaults[.server_secure_port],
      server_protocol: Defaults[.server_protocol],
      rtmp_port: "",
      timezone: "",
      timestamp_now: 0,
      time_now: ""
    )

    var username: String = Defaults[.username]

    var password: String = Defaults[.password]

    func login(username: String, password: String) async {
      self.username = username
      self.password = password
      await login()
    }

    func fetch(_ type: API.FetchType) {
      Task.init {
        switch type {
        case .streams:
          try await self.updateStreams()
          break
        case .epg:
          try await self.updateEPG()
          break
        case .schedule:
          try await self.updateSchedule()
          break
        case .livescore:
          try await self.updateLivescore()
          break
        case .sports:
          try await self.updateSports()
          break
        }
      }
    }

    func login() async {
      DispatchQueue.main.async {
        self.state = .loading
      }
      if username.count == 0 || password.count == 0 {
        DispatchQueue.main.async {
          self.state = .error
          self.error = API.Exception.invalidLogin("new app")
          NotificationCenter.default.post(name: .openWindow, object: WindowController.prefences)
        }
        return
      }
      do {
        _ = try await self.updateUser()
        NotificationCenter.default.post(name: .loggedin, object: nil)

        if Stream.needUpdate() {
          try await updateStreams()
        }
        else {
          NotificationCenter.default.post(name: .updatestreams, object: nil)
        }
        if Schedule.needUpdate() {
          try await updateSchedule()
        }
        else {
          NotificationCenter.default.post(name: .updateschedule, object: nil)
        }
        NotificationCenter.default.post(name: .loaded, object: nil)
        DispatchQueue.main.async {
          self.state = .started
        }
        if EPG.needUpdate() {
          try await updateEPG()
        }
        else {
          DispatchQueue.main.async {
            self.epgState = .loaded
            NotificationCenter.default.post(name: .updateepg, object: nil)
          }
        }
        try await self.updateSports()
      }
      catch let error {
        DispatchQueue.main.async {
          self.state = .error
          self.error = API.Exception.invalidLogin(error.localizedDescription)
        }
      }
    }

    func updateUser() async throws {
      do {
        let response: LoginResponse =
          try await fetchCodable(url: Endpoint.Login, codable: LoginResponse.self)
          as! API.LoginResponse

        DispatchQueue.main.async {
          self.user = response.user_info
          self.server_info = response.server_info
          Defaults[.userinfo] = response.user_info
          Defaults[.serverinfo] = response.server_info
          if let exp_date = self.user?.exp_date {
            let dt = Date(timeIntervalSince1970: TimeInterval(Int64(exp_date)!))
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            self.expires = formatter.localizedString(for: dt, relativeTo: Date())
          }
          self.state = .loggedin
        }
      }
      catch let error {
        guard let storedUser = Defaults[.userinfo] as UserInfo? else {
          throw error
        }
        guard let storedServer = Defaults[.serverinfo] as ServerInfo? else {
          throw error
        }

        guard storedUser.username != "" && storedServer.url != "" else {
          throw error
        }

        DispatchQueue.main.async {
          self.user = storedUser
          self.server_info = storedServer
          if let exp_date = self.user?.exp_date {
            let dt = Date(timeIntervalSince1970: TimeInterval(Int64(exp_date)!))
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            self.expires = formatter.localizedString(for: dt, relativeTo: Date())
          }
          self.state = .loggedin
        }
      }
    }

    func updateSchedule() async throws {
      DispatchQueue.main.async {
        self.loading = .schedule
      }
      try await Schedule.fetch(url: Endpoint.Schedule) { _ in
        DispatchQueue.main.async {
          Task.detached {
            do {
              try await Schedule.delete(Schedule.clearQuery)
            }
            catch let error {
              logger.error("\(error.localizedDescription)")
            }
          }
          Defaults[.scheduleUpdated] = Date()
          self.loading = .loaded
          NotificationCenter.default.post(name: .updateschedule, object: nil)
        }
      }
    }

    func updateStreams() async throws {
      DispatchQueue.main.async {
        self.loading = .category
      }
      try await Category.fetch(url: Endpoint.Categories) { _ in
        DispatchQueue.main.async {
          Task.detached {
            do {
              try await Category.delete(Category.clearQuery)
            }
            catch let error {
              logger.error("\(error.localizedDescription)")
            }
          }
          self.loading = .stream
        }
      }

      try await Stream.fetch(url: Endpoint.Streams) { _ in
        DispatchQueue.main.async {
          Task.detached {
            do {
              try await Stream.delete(Stream.clearQuery)
            }
            catch let error {
              logger.error("\(error.localizedDescription)")
            }
          }
          Defaults[.streamsUpdated] = Date()
          NotificationCenter.default.post(name: .updatestreams, object: nil)
          self.loading = .loaded
        }
      }
    }

    func updateEPG() async throws {
      DispatchQueue.main.async {
        self.loading = .epg
        self.epgState = .loading
      }
      try await EPG.fetch(url: Endpoint.EPG) { _ in
        DispatchQueue.main.async {
          Task.detached {
            do {
              try await EPG.delete(EPG.clearQuery)
            }
            catch let error {
              logger.error("\(error.localizedDescription)")
            }
            Defaults[.epgUpdated] = Date()
            self.epgState = .loaded
            self.loading = .loaded
            NotificationCenter.default.post(name: .updateepg, object: nil)
          }
        }
      }
    }

    func updateLivescore() async throws {
      Livescore.state = .loading
      try await Livescore.fetch(url: Endpoint.Livescores) { _ in

        DispatchQueue.main.async {
          Task.detached {
            do {
              try await Livescore.delete(Livescore.clearQuery)
              Livescore.state = .ready
            }
            catch let error {
              logger.error("\(error.localizedDescription)")
            }
          }
        }
        return
      }
    }

    func updateSports() async throws {
      try await Sport.fetch(url: Endpoint.Sports) { _ in
        DispatchQueue.main.async {
          Task.detached {
            do {
              try await Sport.delete(Sport.clearQuery)
            }
            catch let error {
              logger.error("\(error.localizedDescription)")
            }
          }
        }
      }
    }

    func fetchData(
      url: URL
    ) async throws -> [[String: Any]] {
      let (json, response) = try await URLSession.shared.data(from: url)
      if response.mimeType != "application/json" {
        throw API.Exception.notJson
      }
      let data =
        try
        (JSONSerialization.jsonObject(with: json, options: [.mutableContainers])
        as! [[String: Any]])
      return data
    }

    func fetchCodable(
      url: URL,
      codable: Codable.Type
    ) async throws -> Decodable {
      let (data, response) = try await URLSession.shared.data(from: url)
      if response.mimeType != "application/json" {
        throw API.Exception.notJson
      }
      let decoder = JSONDecoder()
      let result = try decoder.decode(LoginResponse.self, from: data)
      return result
    }
  }

}
