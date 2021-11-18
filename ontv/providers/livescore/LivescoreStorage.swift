//
//  Streams.swift
//  Streams
//
//  Created by Alex on 15/10/2021.
//

import CoreStore
import Foundation

enum LivescoreStorage {

  private static var active: [ContentToggle] = []
  private static var timer: DispatchSourceTimer!

  static let events = Events()
  static let ticker = Ticker()

  static func toggle(_ content: ContentToggle) {
    if active.contains(content) {
      active.removeAll(where: { $0 == content })
      switch content {
      case .livescores:
        events.active = false
        break
      default:
        break
      }
    }
    else {
      active.append(content)
      switch content {
      case .livescores:
        events.active = true
        break
      default:
        break
      }
    }
    if active.count > 0 {
      return startTimer()
    }

    guard timer == nil || timer.isCancelled else {
      return timer.cancel()
    }
  }

  static func startTimer() {
    if timer != nil && !timer.isCancelled {
      return
    }
    timer = DispatchSource.makeTimerSource()
    timer.schedule(deadline: .now(), repeating: .seconds(60))
    timer.setEventHandler {
      Task.detached {
        try! await API.Adapter.updateLivescore()
      }
    }
    timer.activate()
  }

}

extension StorageProvider where EntityType == Livescore {

  static var emptyWhere: Where<EntityType> {
    Where<EntityType>(NSPredicate(value: false))
  }

  static var allWhere: Where<EntityType> {
    Where<EntityType>(NSPredicate(value: true))
  }

  static var dataStack: DataStack {
    CoreStoreDefaults.dataStack
  }

  static var center: NotificationCenter {
    NotificationCenter.default
  }

  static var mainQueue: OperationQueue {
    OperationQueue.main
  }

  func observe() {
  }

  func fetch() {

  }

  func update() {

  }

  func onChangeStream(stream: Stream) {}
}
