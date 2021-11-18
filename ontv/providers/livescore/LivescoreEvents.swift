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

    @Published var active: Bool = false

    override init() {
      self.list = Self.dataStack.publishList(
        From<Livescore>()
          .where(self.query)
          .orderBy(self.order)
      )
      super.init()
    }

    func get(_ id: String) -> ObjectPublisher<Livescore>? {

      guard id.count > 0 else {
        return nil
      }
      guard let ls = self.list.snapshot.first(where: {$0.id == id})  else {
        return nil
      }
      guard let instance = ls.asPublisher(in: Livescore.dataStack) as ObjectPublisher<Livescore>?
      else {
        return nil
      }
      return instance
    }

  }
}
