//
//  Streams.swift
//  Streams
//
//  Created by Alex on 15/10/2021.
//

import CoreStore
import Foundation

enum LivescoreStorage {
  static let events = Events()
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

  func onChangeStream(stream: Stream) {}
}
