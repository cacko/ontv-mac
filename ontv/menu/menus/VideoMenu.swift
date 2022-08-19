//
//  Video.swift
//  Video
//
//  Created by Alex on 03/10/2021.
//

import Defaults
import Foundation
import SwiftUI

class ZoomItem: BaseItem {

  var zoom: Video.Zoom

  init(
    title: String,
    action: Selector?,
    keyEquivalent: String,
    zoom: Video.Zoom
  ) {
    self.zoom = zoom
    super.init(title: title, action: action, keyEquivalent: keyEquivalent)
  }

}

class VideoMenu: BaseMenu {

  override var actions: [NSMenuItem] {
    [
      NoModifierItem(
        title: "Always on top",
        action: #selector(onAlwaysOnTop(sender:)),
        keyEquivalent: "a"
      ),
      NoModifierItem(
        title: "Toggle full screen",
        action: #selector(onToggleFullscreen(sender:)),
        keyEquivalent: "f"
      ),
      NoModifierItem(
        title: "Minimize",
        action: #selector(onMinimize(sender:)),
        keyEquivalent: "\u{1b}"
      ),
      ToggleItem(
        title: "Toggle title",
        action: #selector(onToggle(sender:)),
        keyEquivalent: "t",
        notification: .title
      ),
      NSMenuItem.separator(),
      ZoomItem(
        title: "Zoom in",
        action: #selector(onZoom(sender:)),
        keyEquivalent: "-",
        zoom: .shrink
      ),
      ZoomItem(
        title: "Zoom out",
        action: #selector(onZoom(sender:)),
        keyEquivalent: "=",
        zoom: .expand
      ),
      NSMenuItem.separator(),
    ]
  }
}
