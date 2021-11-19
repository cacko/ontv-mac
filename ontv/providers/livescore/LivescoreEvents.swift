//
//  StreamSearch.swift
//  craptv
//
//  Created by Alex on 29/10/2021.
//

import CoreStore
import Defaults
import Foundation
import OpenGL
import SwiftDate
import SwiftUI

extension LivescoreStorage {

  class Events: NSObject, ObservableObject, ObjectProvider, StorageProvider, AutoScrollProvider {

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

    override init() {
      self.list = Self.dataStack.publishList(
        From<Livescore>()
          .where(self.query)
          .orderBy(self.order)
      )

      self.scrollGenerator = LivescoreScrollGenerator(self.list)
      self.scrollCount = self.scrollGenerator.count

      super.init()

      Self.center.addObserver(forName: .updatelivescore, object: nil, queue: Self.mainQueue) { _ in
        try? self.list.refetch(
          From<Livescore>()
            .where(self.query)
            .orderBy(self.order),
          sourceIdentifier: nil
        )
      }
    }

    func get(_ id: String) -> ObjectPublisher<Livescore>? {

      guard id.count > 0 else {
        return nil
      }
      guard let ls = self.list.snapshot.first(where: { $0.$id == id }) else {
        return nil
      }
      guard let instance = ls.asPublisher(in: Livescore.dataStack) as ObjectPublisher<Livescore>?
      else {
        return nil
      }
      return instance
    }

    var scrollTimer: DispatchSourceTimer!
    var settings: DefaultsObservation!
    var scrollGenerator: LivescoreScrollGenerator
    @Published var scrollTo: String = ""
    @Published var scrollCount: Int = 0

    @Published var active: Bool = false {
      didSet {
        guard self.active else {
          settings.invalidate()
          return scrollTimer.cancel()
        }
        self.startScrollTimer()
        self.startScrollObserver()
      }
    }

    func startScrollTimer() {
      self.scrollGenerator.reset()
      scrollTimer = DispatchSource.makeTimerSource()
      scrollTimer.schedule(deadline: .now(), repeating: .seconds(3))
      scrollTimer.setEventHandler {
        DispatchQueue.main.async {
          self.scrollTo = self.scrollGenerator.next()
        }
      }
      scrollTimer.activate()
    }

    func startScrollObserver() {
      self.settings = Defaults.observe(.ticker) { change in
        self.scrollGenerator = LivescoreScrollGenerator(self.list)
        self.scrollCount = self.scrollGenerator.count
      }
    }
  }
}
