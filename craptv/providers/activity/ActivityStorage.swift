//
//  EPGStorage.swift
//  EPGStorage
//
//  Created by Alex on 12/10/2021.
//

import Combine
import CoreStore
import Foundation
import SwiftUI

enum ActivityListToggleType {
  case state
}

class ActivityStorage {

  private static var _active: ContentToggle?
  
  static let activityepg = ActivityEPGList()
  

  static var active: ContentToggle? {
    get {
      Self._active ?? nil
    }
    set {
      Self._active = Self._active == newValue ? nil : newValue
      Player.instance.contentToggle = self._active
    }
  }
}

protocol AcitvityStorageProtocol {
  var query: Where<Activity> { get set }

  var order: OrderBy<Activity> { get set }
}

class ActivityStorageAbstract: NSObject, ObservableObject, AcitvityStorageProtocol {
  var query = Where<Activity>("1=0")

  var order = OrderBy<Activity>(
    .descending("last_visit"),
    .ascending("favourite"),
    .descending("visits")
  )

  @Published var list: ListPublisher<Activity>

  @Published var state: EPGState = .notavail

  var timer: DispatchSourceTimer!

  let dataStack = CoreStoreDefaults.dataStack

  let player = Player.instance

  var cancellables = Set<AnyCancellable>()

  override init() {
    self.list = self.dataStack.publishList(
      From<Activity>()
        .where(self.query)
        .orderBy(self.order)
    )
    super.init()
    self.postInit()
  }

  func postInit() {
    //        let center = NotificationCenter.default
    //        let mainQueue = OperationQueue.main
    //
    //        center.addObserver(forName: .changeStream, object: nil, queue: mainQueue) { note in
    //            if let stream = note.object as? Stream {
    //                EPGStorage.onChangeStream(stream: stream)
    //            }
    //        }
    //
    //        center.addObserver(forName: .updateepg, object: nil, queue: mainQueue) { _ in
    //            self.update()
    //        }
    self.update()
  }

  func onChangeStream(stream: Stream) {

  }

  func fetch() {
    do {
      try self.list.refetch(
        From<Activity>()
          .where(self.query)
          .orderBy(self.order),
        sourceIdentifier: nil
      )
      self.state = .loaded
    }
    catch {
      logger.error("\(error.localizedDescription)")
    }
  }

  func update() {
    self.state = .loaded
    self.fetch()
    if self.timer != nil {
      self.timer.activate()
    }
  }
}
