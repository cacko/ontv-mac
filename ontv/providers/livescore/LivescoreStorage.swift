//
//  Streams.swift
//  Streams
//
//  Created by Alex on 15/10/2021.
//

import CoreStore
import Foundation

enum LivescoreStorage {
  
  static var active: [ContentToggle] = []
  static var timer: DispatchSourceTimer!
  
  static var timerIsActive: Bool {
    timer != nil && !timer.isCancelled
  }
  
  static let events = Events()
  
  static func toggle(_ content: ContentToggle) {
    guard active.contains(content) else {
      return Self.enable(content)
    }
    Self.disable(content)
  }
  
  static func enable(_ content: ContentToggle) {
    guard !active.contains(content) else {
      return
    }
    active.append(content)
    switch content {
    case .livescoresticker:
      events.active = true
    default:
      break
    }
    
    guard active.count > 0 else {
      return
    }
    startTimer()
  }
  
  static func disable(_ content: ContentToggle) {
    guard active.contains(content) else {
      return
    }
    active.removeAll(where: { $0 == content })
    switch content {
    case .livescoresticker:
      events.active = false
    default:
      break
    }
    guard timerIsActive else {
      return
    }
    timer.cancel()
  }
  
  static func startTimer() {
    guard !timerIsActive else {
      return
    }
    timer = DispatchSource.makeTimerSource()
    timer.schedule(deadline: .now(), repeating: .seconds(60))
    timer.setEventHandler {
      Task.detached {
        try await API.Adapter.updateLivescore()
      }
    }
    timer.activate()
  }
}

extension StorageProvider where EntityType == Livescore {
  
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
