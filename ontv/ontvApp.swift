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
  static let isFloating = Key<Bool>("isFloating", default: true)
  static let leaguesUpdated = Key<Date>("leaguesTimestamp", default: Date(timeIntervalSince1970: 0))
  static let leagues = Key<Set<Int>>(
    "livescoreLeague",
    default: Set([
      8,
      25,
      17,
      11,
      13,
      7,
      6265,
      163,
      350,
      5668,
      573,
      5421,
      7016,
      7685,
      572,
      15,
      167,
      9,
      20,
    ])
  )
  static let tickerPosition = Key<Int>("tickerPosition", default: TickerPosition.top.rawValue)
  static let avBufferTime = Key<Double>("avBufferTime", default: 10)
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
