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

class ScheduleMenu: BaseMenu, NSMenuDelegate, CollectionMenu {
  override var actions: [NSMenuItem] {
    [
      NSMenuItem.separator(),
      FetchItem(
        title: "Update schedule",
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

  func updateMenus() {
    self.removeAllItems()
    (Schedule.getAll() as [LazyStreams]).filter { $0.hasExpired }
      .forEach { (item: LazyStreams) in
        let m = ScheduleItem(action: #selector(onSchedule(sender:)), corelazy: item)
        m.target = self
        addItem(m)
        let submenu = ScheduleStreamsMenu(title: "", parent: parent, corelazy: item)
        m.submenu = submenu
      }
    super._init()
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
