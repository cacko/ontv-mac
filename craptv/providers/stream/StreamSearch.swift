//
//  StreamSearch.swift
//  craptv
//
//  Created by Alex on 29/10/2021.
//

import CoreStore
import Foundation

extension StreamStorage {

  class Search: NSObject, ObservableObject, StorageProviderProtocol {

    typealias EntityType = Stream

    var timer: DispatchSourceTimer! = nil

    var selectedId: Int = 0 {
      didSet {
        objectWillChange.send()
      }
    }

    @Published var search: String = "" {
      didSet {
        self.update()
      }
    }

    var query: Where<Stream> = Where<Stream>("1=0")

    var order: OrderBy<Stream> = Stream.orderBy

    var list: ListPublisher<Stream> {
      didSet {
        objectWillChange.send()
      }
    }

    var selected: ObjectPublisher<Stream>! {
      didSet {
        objectWillChange.send()
      }
    }

    override init() {
      self.list = Self.dataStack.publishList(
        From<Stream>()
          .where(self.query)
          .orderBy(self.order)
      )
      super.init()
      self.observe()
      guard let stream = Player.instance.stream as Stream? else {
        return
      }
      self.onChangeStream(stream: stream)
    }

    func update() {
      guard search.count > 2 else {
        return
      }

      let terms = search.split(separator: " ")
      self.query = Where<Stream>(
        NSCompoundPredicate(
          type: .and,
          subpredicates: terms.map { NSPredicate(format: "name CONTAINS[c] %@", $0 as CVarArg) }
        )
      )
      self.fetch()
    }
    
    func onNavigate(_ notification: Notification) {
      print("kira mi janko")
    }
    
    func selectNext() throws {
      print("kira mi janko")
      
    }
    
    func selectPrevious() throws {
      print("kira mi janko")
      
    }
    
  }
}
