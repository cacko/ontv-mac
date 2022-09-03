//
//  Schedule.swift
//  Schedule
//
//  Created by Alex on 03/10/2021.
//

import Foundation
import SwiftUI

class ScheduleStreamsMenu: StreamsSubmenu {
  override var actions: [NSMenuItem] {
    []
  }
}

class LivescoreMenu: BaseMenu, NSMenuDelegate {
  override var actions: [NSMenuItem] {
    [
      ToggleItem(
        title: "Toggle Sidebar",
        action: #selector(onToggle(sender:)),
        keyEquivalent: "r",
        notification: .livescores
      ),
      BaseItem(
        title: "Toggle Ticker",
        action: #selector(onTickerToggle(sender:)),
        keyEquivalent: "t"
      ),
      ShiftModifierItem(
        title: "Toggle Position",
        action: #selector(onTickerPositionToggle(sender:)),
        keyEquivalent: "t"
      ),
    ]
  }
}

class UpdateScheduleItem: FetchItem {

  let api = API.Adapter
  let center = NotificationCenter.default
  let mainQueue = OperationQueue.main

  override init(
    title: String,
    action: Selector?,
    keyEquivalent: String,
    notification: API.FetchType
  ) {
    super.init(
      title: title,
      action: action,
      keyEquivalent: keyEquivalent,
      notification: notification
    )

    center.addObserver(forName: .updateschedule, object: nil, queue: mainQueue) { _ in
      self.isHidden = false
    }

    center.addObserver(forName: .loaded, object: nil, queue: mainQueue) { _ in
      self.isHidden = false
    }

    center.addObserver(forName: .fetch, object: nil, queue: mainQueue) { note in
      guard let notification = note.object as? API.FetchType else {
        return
      }

      guard notification == .schedule else {
        return
      }
      DispatchQueue.main.async {
        self.isHidden = true
      }
    }

    self.isHidden = api.loading == .schedule
  }
}

class ScheduleMenu: BaseMenu, NSMenuDelegate, CollectionMenu {
  override var actions: [NSMenuItem] {
    [
      ToggleItem(
        title: "Toggle Schedule",
        action: #selector(onToggle(sender:)),
        keyEquivalent: "s",
        notification: .schedule
      ),
      UpdateScheduleItem(
        title: "Update Schedule",
        action: #selector(onFetch(sender:)),
        keyEquivalent: "",
        notification: .schedule
      ),
    ]
  }

  override func observe() {
    center.addObserver(forName: .updateschedule, object: nil, queue: mainQueue) { _ in
      if let updateItem = self.items.filter({ $0.title == "Update schedule" }).first {
        updateItem.isHidden = false
      }
      self.updateMenus()
    }
    center.addObserver(forName: .loaded, object: nil, queue: mainQueue) { _ in
      self.updateMenus()
    }
  }

  override func _init() {
    super._init()
    let item = NSMenuItem(title: "Livescore", action: nil, keyEquivalent: "")
    item.target = self
    addItem(item)
    let menu = LivescoreMenu(title: "", parent: parent)
    item.submenu = menu
    addItem(NSMenuItem.separator())
  }

  func updateMenus() {
    self.removeAllItems()
    self._init()
      (Schedule.getAll() as [LazyStreams])
      .forEach { (item: LazyStreams) in
        if !item.hasExpired {
          let m = ScheduleItem(action: #selector(onSchedule(sender:)), corelazy: item)
          m.target = self
          addItem(m)
          let submenu = ScheduleStreamsMenu(title: "", parent: parent, corelazy: item)
          m.submenu = submenu
        }
      }
    DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
      self.removeExpired()
    }
  }

  func removeExpired() {
    items.forEach { item in
      if let it = item as? LazyStreams {
        if it.hasExpired {
          self.removeItem(item)
        }
      }
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
      self.removeExpired()
    }
  }
}
