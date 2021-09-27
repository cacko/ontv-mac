//
//  Streams.swift
//  Streams
//
//  Created by Alex on 03/10/2021.
//

import Defaults
import Foundation
import SwiftUI

class RecentMenu: StreamsSubmenu {

  static let NUM_ITEMS = 10

  required init(
    title: String,
    parent: Menu,
    corelazy: LazyStreams
  ) {
    super.init(title: title, parent: parent, corelazy: corelazy)
    center.addObserver(forName: .updaterecent, object: nil, queue: mainQueue) { _ in
      Task.init {
        self.loaded = false
        self.removeAllItems()
        await self.load()
      }
    }
  }

  @available(*, unavailable)
  required init(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  override var actions: [NSMenuItem] {
    []
  }
}

class RecentCoreLazy: LazyStreams {
  static let expiresIn: TimeInterval = TimeInterval(0)

  var startTime: Date {
    Date()
  }

  var hasExpired: Bool {
    false
  }

  var Streams: [LazyStream] {
    Provider.Stream.RecentItems.streams
  }

  var title: String = "Recent"
}

class StreamMenu: BaseMenu {
  var quickStreams = Provider.Stream.QuickStreams

  var recent = Provider.Stream.Recent

  static let NUM_BOOKMARKS = 5

  override var actions: [NSMenuItem] {
    let recentMenuItem = NoModifierItem(
      title: "Recent",
      action: #selector(onRecent(sender:)),
      keyEquivalent: ""
    )
    let submenu = RecentMenu(title: "", parent: parent, corelazy: RecentCoreLazy())
    recentMenuItem.submenu = submenu

    return [
      NSMenuItem.separator(),
      recentMenuItem,
      NavigationItem(
        title: "Previous",
        action: #selector(onHistory(sender:)),
        keyEquivalent: "\u{2190}",
        notification: .next
      ),
      NavigationItem(
        title: "Next",
        action: #selector(onHistory(sender:)),
        keyEquivalent: "\u{2192}",
        notification: .previous
      ),
      NSMenuItem.separator(),
      BaseItem(
        title: "Reload",
        action: #selector(onReload(sender:)),
        keyEquivalent: "r"
      ),
      ToggleItem(
        title: "Search",
        action: #selector(onToggle(sender:)),
        keyEquivalent: "/",
        notification: .search
      ),
      NoModifierItem(
        title: "Bookmark",
        action: #selector(onBookmark(sender:)),
        keyEquivalent: "b"
      ),
      ToggleItem(
        title: "Info",
        action: #selector(onToggle(sender:)),
        keyEquivalent: "i",
        notification: .metadata
      ),
      NSMenuItem(
        title: "Preferences",
        action: #selector(onPreferences(sender:)),
        keyEquivalent: ","
      ),
    ]
  }

  override func _init() {

    super._init()

  }

  override func observe() {
    center.addObserver(forName: .updatebookmarks, object: nil, queue: mainQueue) { _ in
      DispatchQueue.main.async {
        self.updateMenus()
      }
    }
  }

  @MainActor func updateMenus() {
    self.removeAllItems()
    let streams = self.quickStreams.streams
    for qs in streams {
      guard qs.isValid else {
        continue
      }
      let newItem = try! QuickItem(
        action: #selector(onStream(sender:)),
        keyEquivalent: String(qs.idx),
        quick: qs
      )
      newItem.target = self
      self.addItem(newItem)
    }
    super._init()
  }
}
