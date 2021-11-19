//
//  StreamSearch.swift
//  craptv
//
//  Created by Alex on 29/10/2021.
//

import CoreStore
import Defaults
import Foundation
import SwiftDate
import SwiftUI

extension LivescoreStorage {

  class Ticker: NSObject, ObservableObject, StorageProvider, AutoScrollProvider {

    typealias EntityType = Livescore
    var list: ListPublisher<EntityType>
    var scrollGenerator: LivescoreScrollGenerator
    var selected: ObjectPublisher<Livescore>!
    var selectedId: String = ""
    var order: OrderBy<Livescore> = Livescore.orderBy
    var search: String = ""
    var state: ProviderState = .notavail
    func selectNext() throws {}
    func selectPrevious() throws {}
    func onNavigate(_ notitication: Notification) {}

    @Published var count: Int = 0

    static func query() -> Where<Livescore> {
      guard let ticker = Defaults[.ticker] as [String]? else {
        return Where<Livescore>(NSPredicate(value: false))
      }
      guard ticker.count > 0 else {
        return Where<Livescore>(NSPredicate(value: false))
      }
      return Where<Livescore>(NSPredicate(format: "ANY id IN %@", ticker as CVarArg))
    }

    var query: Where<Livescore> {
      get {
        Self.query()
      }
      set {}
    }

    @Published var active: Bool = false {
      didSet {
        guard self.active else {
          objectWillChange.send()
          return timer.cancel()
        }
        self.startTimer()
        objectWillChange.send()
      }
    }

    @Published var scrollTo: String = ""

    var timer: DispatchSourceTimer!

    override init() {
      self.list = Self.dataStack.publishList(
        From<Livescore>()
          .where(Self.query())
          .orderBy(self.order)
      )
      self.scrollGenerator = LivescoreScrollGenerator(self.list)
      self.count = self.scrollGenerator.count
      super.init()

      let center = NotificationCenter.default
      let mainQueue = OperationQueue.main
      center.addObserver(forName: .tickerupdated, object: nil, queue: mainQueue) { _ in
        try! self.list.refetch(
          From<Livescore>()
            .where(self.query)
            .orderBy(self.order),
          sourceIdentifier: nil
        )
        self.scrollGenerator = LivescoreScrollGenerator(self.list)
        self.count = self.scrollGenerator.count
      }
    }

    func startTimer() {
      self.scrollGenerator.reset()
      timer = DispatchSource.makeTimerSource()
      timer.schedule(deadline: .now(), repeating: .seconds(3))
      timer.setEventHandler {
        DispatchQueue.main.async {
          self.scrollTo = self.scrollGenerator.next()
        }
      }
      timer.activate()
    }
  }
}
