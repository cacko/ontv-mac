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

  class Events: NSObject, ObservableObject, ObjectProvider, StorageProvider, AutoScrollProvider,
    TicketProvider
  {

    typealias EntityType = Livescore

    var list: ListPublisher<EntityType>

    var selected: ObjectPublisher<Livescore>!

    var selectedId: String = ""

    var query: Where<Livescore>

    var order: OrderBy<Livescore> = Livescore.orderBy

    var search: String = ""
    
    static let LEAGUES: Set<Int> = Set([43, 41, 44, 45, 39, 256])

    var state: ProviderState = .notavail

    func selectNext() throws {}

    func selectPrevious() throws {}

    func onNavigate(_ notitication: Notification) {}

    override init() {
      self.query = Where<Livescore>(NSPredicate(format: "league_id IN %@", Self.LEAGUES))
      self.list = Self.dataStack.publishList(
        From<Livescore>()
          .where(self.query)
          .orderBy(self.order)
      )

      self.scrollGenerator = LivescoreScrollGenerator(self.list)
      self.scrollCount = self.scrollGenerator.count
      super.init()
      self.tickerVisible = self.scrollCount > 0
      self.tickerAvailable = self.scrollCount > 0
    }

    func update(_ livescore: Livescore) {
      self.active = false
      Task.init {
        try await livescore.toggleTicker() {_ in
          self.scrollGenerator.update()
          DispatchQueue.main.async {
            self.scrollCount = self.scrollGenerator.count
            self.tickerVisible = self.scrollCount > 0
            self.tickerAvailable = self.scrollCount > 0
            guard self.tickerVisible else {
              return
            }
            self.active = true
          }
        }
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
    var scrollGenerator: LivescoreScrollGenerator
    @Published var scrollTo: String = ""
    @Published var scrollCount: Int = 0

    @Published var active: Bool = false {
      didSet {
        guard self.active else {
          if scrollTimer != nil, !scrollTimer.isCancelled {
            return scrollTimer.cancel()
          }
          return
        }
        guard scrollTimer != nil else {
          return startScrollTimer()
        }
        guard !scrollTimer.isCancelled else {
          return startScrollTimer()
        }
      }
    }

    @Published var tickerVisible: Bool = false {
      didSet {
        LivescoreStorage.toggle(.livescoresticker)
      }
    }
    @Published var tickerAvailable: Bool = false


    func startScrollTimer() {
      self.scrollGenerator.reset()
      scrollTimer = DispatchSource.makeTimerSource()
      scrollTimer.schedule(deadline: .now(), repeating: .seconds(3))
      scrollTimer.setEventHandler {
        guard Livescore.state == .ready else {
          return
        }
        DispatchQueue.main.async {
          self.scrollTo = self.scrollGenerator.next()
        }
      }
      scrollTimer.activate()
    }
  }
}
