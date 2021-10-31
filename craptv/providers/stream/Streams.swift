//
//  Streams.swift
//  Streams
//
//  Created by Alex on 15/10/2021.
//

import CoreStore
import Foundation

enum StreamStorage {

  static let category = Category()

  static let search = Search()
}

extension StorageProviderProtocol where EntityType == Stream {

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

    Self.center.addObserver(
      forName: .changeStream,
      object: nil,
      queue: Self.mainQueue
    ) { note in
      if let stream = note.object as? Stream {
        self.onChangeStream(stream: stream)
      }
    }

    Self.center.addObserver(
      forName: .navigate,
      object: nil,
      queue: Self.mainQueue
    ) { note in
      self.onNavigate(note)
    }

    Self.center.addObserver(forName: .list_navigate, object: nil, queue: Self.mainQueue) {
      note in

      guard let action = note.object as? ListNavigation else {
        return
      }

      do {
        switch action {
        case .down:
          try self.selectNext()
        case .up:
          try self.selectPrevious()
        case .select:
          NotificationCenter.default.post(name: .selectStream, object: self.selected.object)
        default:
          logger.info("eat shit")
        }
      }
      catch let error {
        logger.error("\(error.localizedDescription)")
      }
    }

  }

  func fetch() {
    do {
      try self.list.refetch(
        From<Stream>()
          .where(self.query)
          .orderBy(self.order),
        sourceIdentifier: nil
      )
    }
    catch {
      logger.error("\(error.localizedDescription)")
    }
  }

  func onChangeStream(stream: Stream) {
    self.selectedId = stream.id
    guard let snapshot = self.list.snapshot as ListSnapshot<Stream>? else {
      return
    }
    guard let foundIdx = snapshot.firstIndex(where: { obj in obj.id == stream.id }) else {
      return
    }

    guard snapshot.indices.contains(foundIdx) else {
      return
    }

    self.selected = snapshot[foundIdx]
  }
}
