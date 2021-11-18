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
      list.snapshot.makeIterator().map { $0.id! }
    }
    set {}
  }

  var itemsSource: ArraySlice<String> = ArraySlice([])

  var isBackwards: Bool = true {
    didSet {
      itemsSource =
        ArraySlice(self.isBackwards ? self.items.reversed() : self.items)
    }
  }

  func reset() {
    isBackwards = false
  }

  func next() -> String {
    guard items.count > 0 else {
      return ""
    }
    if itemsSource.count == 0 {
      isBackwards.toggle()
    }
    return itemsSource.popFirst()!
  }

}
