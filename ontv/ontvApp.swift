//
//  craptvApp.swift
//  craptv
//
//  Created by Alex on 27/09/2021.
//

import AppKit
import Combine
import CoreStore
import Defaults
import Preferences
import SwiftUI
import os

let logger = Logger(subsystem: "net.cacko.ontv", category: "video")

extension Defaults.Keys {
  static let server_host = Key<String>("server_host", default: "rd-media.xyz")
  static let server_port = Key<String>("server_port", default: "8080")
  static let server_protocol = Key<String>("server_protocol", default: "http")
  static let server_secure_port = Key<String>("server_secure_port", default: "25463")
  static let username = Key<String>("username", default: "")
  static let password = Key<String>("password", default: "")
  static let streamsUpdated = Key<Date>("streamsUpdated", default: Date(timeIntervalSince1970: 0))
  static let scheduleUpdated = Key<Date>("scheduleUpdated", default: Date(timeIntervalSince1970: 0))
  static let epgUpdated = Key<Date>("epgUpdated", default: Date(timeIntervalSince1970: 0))
  static let volume = Key<Float>("volume", default: 100)
  static let vendor = Key<PlayVendor>("vender", default: .ffmpeg)
  static let isFloating = Key<Bool>("isFloating", default: true)
  static let liveScoreLeagues = Key<Set<Int64>>("livescoreLeague", default: Set([43, 41, 44, 45, 39, 256, 84, 247, 558,246,147,195,2442,625,31,908]))
}

protocol Reorderable {
  associatedtype OrderElement: Equatable
  var orderElement: OrderElement { get }
}

extension Array where Element: Reorderable {
  func reorder(by preferredOrder: [Element.OrderElement]) -> [Element] {
    sorted {
      guard let first = preferredOrder.firstIndex(of: $0.orderElement) else {
        return false
      }

      guard let second = preferredOrder.firstIndex(of: $1.orderElement) else {
        return true
      }

      return first < second
    }
  }
}

@main
struct ontvApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  init() {
    Schema.addStorageAndWait()
  }

  var body: some Scene {
    WindowGroup {}
  }
}

enum AppNavigation {
  case previous, next, select
}

enum ListNavigation {
  case up, down, left, right, select
}
