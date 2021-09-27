//
//  Audio.swift
//  Audio
//
//  Created by Alex on 03/10/2021.
//

import Foundation
import SwiftUI

class EPGMenu: BaseMenu {
  override var actions: [NSMenuItem] {
    [
      ToggleItem(
        title: "Toggle EPG",
        action: #selector(onToggle(sender:)),
        keyEquivalent: "p",
        notification: .guide
      ),
      NSMenuItem.separator(),

      ToggleItem(
        title: "Recents Guide",
        action: #selector(onToggle(sender:)),
        keyEquivalent: "l",
        notification: .activityepg
      ),
      ToggleInverseItem(
        title: "TV Guide",
        action: #selector(onToggle(sender:)),
        keyEquivalent: "l",
        notification: .epglist
      ),
      NSMenuItem.separator(),
      FetchItem(
        title: "Update EPG",
        action: #selector(onFetch(sender:)),
        keyEquivalent: "",
        notification: .epg
      ),
      NSMenuItem.separator(),
      ListNavigationItem(
        title: "Left",
        action: #selector(onListNavigation(sender:)),
        keyEquivalent: "\u{2190}",
        notification: .left
      ),
      ListNavigationItem(
        title: "Right",
        action: #selector(onListNavigation(sender:)),
        keyEquivalent: "\u{2192}",
        notification: .right
      ),
      ListNavigationItem(
        title: "Up",
        action: #selector(onListNavigation(sender:)),
        keyEquivalent: "\u{2191}",
        notification: .up
      ),
      ListNavigationItem(
        title: "Down",
        action: #selector(onListNavigation(sender:)),
        keyEquivalent: "\u{2193}",
        notification: .down
      ),
      ListNavigationItem(
        title: "Select",
        action: #selector(onListNavigation(sender:)),
        keyEquivalent: "\u{0d}",
        notification: .select
      ),
    ]
  }

  override func observe() {
    center.addObserver(forName: .updateepg, object: nil, queue: mainQueue) { _ in
      if let updateItem = self.items.filter({ $0.title == "Update EPG" }).first {
        updateItem.isHidden = false
      }
    }
  }
}
