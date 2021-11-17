//
//  ScrollGenerator.swift
//  ontv
//
//  Created by Alex on 17/11/2021.
//

import Foundation

protocol ScrollGenerator {
  var items: [String] { get set }
  var itemsSource: ArraySlice<String> { get set }
  var isBackwards: Bool { get set }
  var count: Int { get }
  init(_ items: [String])
  func reset()
  func next() -> String
}

extension Provider.Generator {

  class Scroll: ScrollGenerator {

    internal var items: [String]
    internal var itemsSource: ArraySlice<String> = ArraySlice([])

    internal var isBackwards: Bool = false {
      didSet {
        if self.isBackwards {
          self.itemsSource = ArraySlice(self.items.reversed())
        }
        else {
          self.itemsSource = ArraySlice(self.items)
        }
      }
    }

    required init(
      _ items: [String]
    ) {
      self.items = items
      self.itemsSource = ArraySlice(items)
    }

    var count: Int {
      self.items.count
    }

    func reset() {
      self.itemsSource = ArraySlice(items)
    }

    func next() -> String {
      guard items.count > 0 else {
        return ""
      }
      if self.itemsSource.count == 0 {
        self.isBackwards.toggle()
      }
      let res = self.itemsSource.popFirst()!
      return res
    }

  }

}
