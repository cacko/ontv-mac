//
//  LivescoreScrollGenerator.swift
//  ontv
//
//  Created by Alex on 17/11/2021.
//

import CoreStore
import Foundation

class LivescoreScrollGenerator: ScrollGeneratorProtocol {

  required init(
    _ list: ListPublisher<Livescore>
  ) {
    self.list = list
  }

  typealias EntityType = Livescore

  var list: ListPublisher<Livescore>

  var items: [String] {
    get {
      self.list.snapshot.makeIterator().filter { $0.inPlay ?? false }.map { $0.id! }
    }
    set {}
  }

  var itemsSource: ArraySlice<String> = ArraySlice([])

  var isBackwards: Bool = true {
    didSet {
      self.itemsSource =
        self.isBackwards ? ArraySlice(self.items.reversed()) : ArraySlice(self.items)
    }
  }

  func reset() {
    self.isBackwards = false
  }

  func next() -> String {
    guard items.count > 0 else {
      return ""
    }
    if self.itemsSource.count == 0 {
      self.isBackwards.toggle()
    }
    return self.itemsSource.popFirst()!
  }

}
