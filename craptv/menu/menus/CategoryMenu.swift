//
//  Category.swift
//  Category
//
//  Created by Alex on 03/10/2021.
//

import Foundation
import SwiftUI

class CategoryStreamsMenu: StreamsSubmenu {
  override var actions: [NSMenuItem] {
    []
  }
}

class CategoryMenu: BaseMenu, NSMenuDelegate, CollectionMenu {
  var streams = Provider.Stream.QuickStreams

  override var actions: [NSMenuItem] {
    [
      FetchItem(
        title: "Update categories",
        action: #selector(onFetch(sender:)),
        keyEquivalent: "",
        notification: .streams
      ),
      NavigationItem(
        title: "Previous",
        action: #selector(onNavigation(sender:)),
        keyEquivalent: "\u{2191}",
        notification: .previous
      ),
      NavigationItem(
        title: "Next",
        action: #selector(onNavigation(sender:)),
        keyEquivalent: "\u{2193}",
        notification: .next
      ),
      ToggleItem(
        title: "Toggle streams",
        action: #selector(onToggle(sender:)),
        keyEquivalent: "c",
        notification: .category
      ),
      NSMenuItem.separator(),
    ]
  }

  override func observe() {
    center.addObserver(forName: .updatestreams, object: nil, queue: mainQueue) { _ in
      self.updateMenus()
      if let updateItem = self.items.filter({ $0.title == "Update categories" }).first {
        updateItem.isHidden = false
      }
    }
    center.addObserver(forName: .loaded, object: nil, queue: mainQueue) { _ in
      self.updateMenus()
    }
  }

  func updateMenus() {
    self.removeAllItems()
    super._init()
    guard let categories = Category.getAll() as [Category]? else {
      return
    }
    for item in categories {
      let m = CategoryItem(action: #selector(onCategory(sender:)), corelazy: item)
      m.target = self
      addItem(m)
      let submenu = CategoryStreamsMenu(title: "", parent: parent, corelazy: item)
      m.submenu = submenu
    }

  }
}
