//
//  Base.swift
//  Base
//
//  Created by Alex on 03/10/2021.
//

import Foundation
import SwiftUI

class BaseMenu: NSMenu {
  let player = Player.instance
  let api = API.Adapter

  var actions: [NSMenuItem] { return [] }

  let center = NotificationCenter.default
  let mainQueue = OperationQueue.main

  var parent: Menu

  init(
    title: String,
    parent: Menu
  ) {
    self.parent = parent
    super.init(title: title)
    _init()
    observe()
  }

  func _init() {
    actions.forEach { item in item.attach(self) }
  }

  func observe() {}

  @available(*, unavailable)
  required init(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func onToggleFullscreen(sender: NSMenuItem) {
    sender.state = sender.state == .on ? .off : .on
    NotificationCenter.default.post(name: .toggleFullscreen, object: nil)
  }

  @objc func onAlwaysOnTop(sender: NSMenuItem) {
    sender.state = sender.state == .on ? .off : .on
    NotificationCenter.default.post(name: .toggleOnTop, object: nil)
  }

  @objc func onQuit(sender: NSMenuItem) {
    NSApplication.shared.terminate(sender)
  }

  @objc func onMinimize(sender: NSMenuItem) {
    NotificationCenter.default.post(name: .minimize, object: nil)
  }

  @objc func onAudioMute(sender: NSMenuItem) {
    sender.state = player.isMuted ? .off : .on
    NotificationCenter.default.post(name: .toggleAudio, object: nil)
  }

  @objc func onStream(sender: StreamItem) {
    NotificationCenter.default.post(name: .selectStream, object: sender)
  }

  @objc func onBookmark(sender: StreamItem) {
    NotificationCenter.default.post(name: .bookmark, object: nil)
  }

  @objc func onNavigation(sender: BaseItem) {

    guard let item = sender as? NavigationItem else {
      return
    }

    guard player.contentToggle == .search else {
      self.player.state = .opening
      NotificationCenter.default.post(name: .navigate, object: item.notification)
      return
    }
    NotificationCenter.default.post(name: .search_navigate, object: item.notification)
  }

  @objc func onHistory(sender: BaseItem) {
    guard player.contentToggle != .search else {
      return
    }
    guard let item = sender as? NavigationItem else {
      return
    }
    NotificationCenter.default.post(name: .recent, object: item.notification)
  }

  @objc func onListNavigation(sender: ListNavigationItem) {
    NotificationCenter.default.post(name: .list_navigate, object: sender.notification)
  }

  @objc func onReload(sender: NSMenuItem) {
    NotificationCenter.default.post(name: .reload, object: nil)
  }

  @objc func onPreferences(sender: StreamItem) {
    NotificationCenter.default.post(name: .openWindow, object: WindowController.prefences)
  }

  @objc func onCategory(sender: CategoryItem) {}

  @objc func onSchedule(sender: ScheduleItem) {}

  @objc func onRecent(sender: NoModifierItem) {}

  @objc func onFetch(sender: FetchItem) {
    guard api.loading == .loaded else {
      return
    }
    NotificationCenter.default.post(name: .fetch, object: sender.notification)
  }

  @objc func onToggle(sender: ToggleItem) {
    NotificationCenter.default.post(name: .contentToggle, object: sender.notification)
  }

  @objc func onAudioCommand(sender: AudioItem) {
    NotificationCenter.default.post(name: .audioCommand, object: sender.parameter)
  }

  @objc func onVendorChange(sender: VendorItem) {
    NotificationCenter.default.post(name: .vendorChange, object: sender.vendor)
  }

  @objc func onZoom(sender: ZoomItem) {
    NotificationCenter.default.post(name: .zoomchange, object: sender.zoom)
  }

  @objc func onTickerToggle(sender: NSMenuItem) {
    LivescoreStorage.events.tickerVisible.toggle()
  }
}

protocol CollectionMenu {
  func updateMenus()
}

protocol StreamSubmenuProtocol {
  var loaded: Bool { get set }

  var corelazy: LazyStreams { get set }

  func load() async

  init(title: String, parent: Menu, corelazy: LazyStreams)
}

class StreamsSubmenu: BaseMenu, StreamSubmenuProtocol {
  var loaded: Bool = false

  var corelazy: LazyStreams

  required init(
    title: String,
    parent: Menu,
    corelazy: LazyStreams
  ) {
    self.corelazy = corelazy
    super.init(title: title, parent: parent)
  }

  @available(*, unavailable)
  required init(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  func load() async {
    guard loaded else {
      DispatchQueue.main.async {
        Task.init {
          let streams = self.corelazy.Streams
          for stream in streams {
            let item = StreamItem(
              action: #selector(self.onStream(sender:)),
              keyEquivalent: "",
              stream: stream as! Stream
            )
            item.target = self
            if let iv = item as? Validity {
              item.isHidden = iv.isValid
            }
            self.addItem(item)
          }
        }
        self.loaded = true
      }

      return
    }
  }
}
