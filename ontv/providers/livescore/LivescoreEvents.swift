//
//  StreamSearch.swift
//  craptv
//
//  Created by Alex on 29/10/2021.
//

import CoreStore
import Foundation
import OpenGL
import SwiftDate
import SwiftUI

extension LivescoreStorage {

  class Events: NSObject, ObservableObject, ObjectProvider, StorageProvider {

    typealias EntityType = Livescore

    var list: ListPublisher<EntityType>

    var selected: ObjectPublisher<Livescore>!

    var selectedId: String = ""

    var query: Where<Livescore> = Where<Livescore>(NSPredicate(value: true))

    var order: OrderBy<Livescore> = Livescore.orderBy

    var search: String = ""

    var state: ProviderState = .notavail

    func selectNext() throws {}

    func selectPrevious() throws {}

    func onNavigate(_ notitication: Notification) {}

    @Published var active: Bool = false {
      didSet {
        guard self.active else {
          return timer.cancel()
        }
        self.startTimer()
      }
    }

    var timer: DispatchSourceTimer!

    override init() {
      self.list = Self.dataStack.publishList(
        From<Livescore>()
          .where(self.query)
          .orderBy(self.order)
      )
      super.init()
    }

    func startTimer() {
      timer = DispatchSource.makeTimerSource()
      timer.schedule(deadline: .now(), repeating: .seconds(60))
      timer.setEventHandler {
        self.update()
      }
      timer.activate()
    }

    func update() {
      Task.init {
        try await API.Adapter.updateLivescore()
      }
    }

    static var instances: [String: ObjectPublisher<Livescore>] = [:]

    func get(_ id: String) -> ObjectPublisher<Livescore>? {

      guard id.count > 0 else {
        return nil
      }

      if Self.instances.keys.contains(id) {
        return Self.instances[id]
      }
      guard let ls = Livescore.get(id.int64) else {
        return nil
      }
      guard let instance = ls.asPublisher(in: Livescore.dataStack) as ObjectPublisher<Livescore>?
      else {
        return nil
      }
      Self.instances[id] = instance
      return instance
    }

  }
}
