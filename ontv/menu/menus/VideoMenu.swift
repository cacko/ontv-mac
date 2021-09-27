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

class VendorItem: BaseItem {
  var vendor: PlayVendor

  init(
    title: String,
    action: Selector?,
    vendor: PlayVendor
  ) {
    self.vendor = vendor
    super.init(title: title, action: action, keyEquivalent: "")
    self.state = Defaults[.vendor] == vendor ? .on : .off

    let center = NotificationCenter.default
    let mainQueue = OperationQueue.main

    center.addObserver(forName: .vendorChange, object: nil, queue: mainQueue) {
      note in
      guard let newVendor = note.object as? PlayVendor else {
        return
      }
      self.state = newVendor == self.vendor ? .on : .off
    }
  }

  override func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
    return false
  }

  @available(*, unavailable)
  required init(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }
}

class VideoRendererMenu: BaseMenu {

  override var actions: [NSMenuItem] {
    Player.instance.availableVendors.map { (vendor: VendorInfo) in
      VendorItem(
        title: vendor.hint,
        action: #selector(onVendorChange(sender:)),
        vendor: vendor.id
      )
    }
  }

  static func item(_ parent: Menu) -> NSMenuItem {
    let item = NSMenuItem(title: "Renderer", action: nil, keyEquivalent: "")
    let menu = VideoRendererMenu(title: "", parent: parent)
    item.submenu = menu
    return item
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
      VideoRendererMenu.item(parent),
    ]
  }
}
