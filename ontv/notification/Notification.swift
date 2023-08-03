//
//  Notification.swift
//  Notification
//
//  Created by Alex on 02/10/2021.
//

import AppKit
import Defaults
import Foundation

extension Notification.Name {
  static let openWindow = NSNotification.Name("open_window")
  static let closeWindow = NSNotification.Name("close_window")
  static let openUrl = NSNotification.Name("open_url")
  static let fullscreen = NSNotification.Name("fullscreen")
  static let updatestreams = NSNotification.Name("updatestream")
  static let updatebookmarks = NSNotification.Name("updatebookmarks")
  static let updateschedule = NSNotification.Name("updateschedule")
  static let selectStream = NSNotification.Name("selectStream")
  static let loggedin = NSNotification.Name("loggedIn")
  static let loaded = NSNotification.Name("loaded")
  static let autoPlayRecent = NSNotification.Name("autoplayRecent")
  static let playerLoaded = NSNotification.Name("playerLoaded")
  static let fit = NSNotification.Name("fittosize")
  static let minimize = NSNotification.Name("minimize")
  static let toggleFullscreen = NSNotification.Name("toggle_fullscreen")
  static let toggleOnTop = NSNotification.Name("toggle_ontop")
  static let bookmark = NSNotification.Name("bookmark")
  static let reload = NSNotification.Name("reload")
  static let updateepg = NSNotification.Name("updateepg")
  static let changeStream = NSNotification.Name("change_stream")
  static let contentToggle = NSNotification.Name("content_toggle")
  static let onTap = NSNotification.Name("ontap")
  static let navigate = NSNotification.Name("navigate")
  static let recent = NSNotification.Name("recent")
  static let updaterecent = NSNotification.Name("updaterecent")
  static let fetch = NSNotification.Name("fetch")
  static let toggleAudio = NSNotification.Name("toggleaudio")
  static let startPlaying = Notification.Name("startplaying")
  static let audioCommand = Notification.Name("audio_command")
  static let audioCommandResult = Notification.Name("audio_command_result")
  static let list_navigate = Notification.Name("list_navigate")
  static let leagues_updates = Notification.Name("leagues_updated")

}

extension AppDelegate {

  func observe() {
    let center = NotificationCenter.default
    let mainQueue = OperationQueue.main

    let player = Player.instance

    let recent = Provider.Stream.Recent

    let quickStreams = Provider.Stream.QuickStreams

    center.addObserver(forName: .openWindow, object: nil, queue: mainQueue) { note in
      let obj: WindowController = note.object as! WindowController
      switch obj {
      case .prefences:
        self.preferencesWindowController.show()
        self.preferencesWindowController.window?.level = .modalPanel
      default:
        break
      }
    }

    center.addObserver(forName: .closeWindow, object: nil, queue: mainQueue) { note in
      let obj: WindowController = note.object as! WindowController
      switch obj {
      case .prefences:
        self.preferencesWindowController.close()
      default:
        break
      }
    }

    center.addObserver(forName: .toggleAudio, object: nil, queue: mainQueue) { _ in
      DispatchQueue.main.async {
        self.player.isMuted.toggle()
      }
    }

    center.addObserver(forName: .toggleFullscreen, object: nil, queue: mainQueue) { _ in

      self.window.isFullScreen.toggle()

      if !self.window.isFullScreen {
        self.window.contentAspectRatio = self.player.size.aspectSize
      }
    }

    center.addObserver(forName: .reaspect, object: nil, queue: mainQueue) { note in
      self.window.contentAspectRatio = self.player.size.aspectSize
      self.window.setContentSize(self.player.size)
      self.window.reaspectPosition()
    }

    center.addObserver(forName: .toggleOnTop, object: nil, queue: mainQueue) { _ in
      self.window.isFloating.toggle()
    }

    center.addObserver(forName: .fetch, object: nil, queue: mainQueue) { note in
      if let fetchType = note.object as? API.FetchType {
        API.Adapter.fetch(fetchType, force: true)
      }
    }

    center.addObserver(forName: .minimize, object: nil, queue: mainQueue) { _ in
      self.preferencesWindowController.close()
      guard [nil, .livescoresticker].contains(self.player.contentToggle) else {
        self.player.contentToggle = nil
        return
      }

      if self.window.isFullScreen {
        return self.window.isFullScreen.toggle()
      }
      NSApp.hide(nil)
    }

    center.addObserver(forName: .selectStream, object: nil, queue: mainQueue) { note in
      guard let streamable = note.object as? Streamable else {
        return
      }
      guard let stream = Stream.get(streamable.stream_id) else {
        return
      }
      self.openStream(stream)
    }

    center.addObserver(forName: .navigate, object: nil, queue: mainQueue) { note in
      guard let navigation = note.object as? AppNavigation else {
        return
      }
      DispatchQueue.main.async {
        Task.init {
          switch navigation {
          case .next:
            await self.player.next()
          case .previous:
            await self.player.prev()
          default:
            return
          }
        }
      }
    }

    center.addObserver(forName: .reload, object: nil, queue: mainQueue) { _ in
      self.player.retry()
    }
    
    center.addObserver(forName: .playerLoaded, object: nil, queue: mainQueue) { _ in
      self.playerLoaded = true
      do {
        sleep(5)
      }
      if self.apiLoaded {
        NotificationCenter.default.post(name: .autoPlayRecent, object: nil)
      }
    }
    
    center.addObserver(forName: .loaded, object: nil, queue: mainQueue) { _ in
      self.apiLoaded = true
      if self.playerLoaded {
        NotificationCenter.default.post(name: .autoPlayRecent, object: nil)
      }
    }
    
    center.addObserver(forName: .autoPlayRecent, object: nil, queue: mainQueue) { _ in
      Task.init {
        await recent.load()
        recent.register()
        await quickStreams.load()
        guard let stream = recent.autoPlay
        else {
          self.player.controlsState = .always
          return
        }
        NotificationCenter.default.post(name: .updatebookmarks, object: nil)
        self.player.play(stream)
      }
    }

    center.addObserver(forName: .contentToggle, object: nil, queue: mainQueue) { note in
      if let t = note.object as? ContentToggle {
        self.player.contentToggle = t
        switch t {
        case .livescoresticker:
          LivescoreStorage.events.tickerVisible.toggle()
        case .category:
          guard let category_id = player.stream?.category_id as Int64? else {
            break
          }
          StreamStorage.category.search = category_id.string
          break
        case .search:
          NSCursor.unhide()
          break
        case .epglist:
          NSCursor.unhide()
        default:
          break
        }
      }
    }

    center.addObserver(forName: .onTap, object: nil, queue: mainQueue) { _ in
      if self.player.contentToggle != nil {
        self.player.contentToggle = nil
        self.fadeTask?.cancel()
      }
      if self.player.controlsState != .always {
        self.player.controlsState = .hidden
      }
    }

    center.addObserver(forName: .bookmark, object: nil, queue: mainQueue) { _ in
      center.post(name: .contentToggle, object: ContentToggle.bookmarks)
      //      Task.init {
      //        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: self.getFadeTak(.bookmarks))
      //      }
    }

    center.addObserver(forName: .startPlaying, object: nil, queue: mainQueue) { note in
      guard let stream = note.object as? Stream else {
        return
      }
      guard stream.isAdult == false else {
        return
      }
      Task.init {
        do {
          try await Provider.Stream.Recent.add(stream)
        }
        catch let error {
          logger.error("\(error.localizedDescription)")
        }
      }
    }

    center.addObserver(forName: .audioCommand, object: nil, queue: mainQueue) { note in
      if let parameter = note.object as? Audio.Parameter {
        self.player.onAudioCommand(parameter)
      }
    }
  }

  private func getFadeTak(_ toggle: ContentToggle) -> DispatchWorkItem {
    if self.fadeTask?.isCancelled != nil {
      self.fadeTask.cancel()
    }
    self.fadeTask = DispatchWorkItem {
      guard self.player.contentToggle == toggle else {
        return
      }
      NotificationCenter.default.post(name: .contentToggle, object: toggle)
    }
    return self.fadeTask
  }

  func openStream(_ stream: Stream) {
    DispatchQueue.main.async {
      self.player.contentToggle = nil
      self.player.play(stream)
      EPGStorage.active = nil
    }
  }

  func restartApp() {
    if let path = Bundle.main.resourceURL?.deletingLastPathComponent()
      .deletingLastPathComponent().absoluteString
    {
      NSLog("restart \(path)")
      _ = Process.launchedProcess(launchPath: "/usr/bin/open", arguments: [path])
      NSApp.terminate(self)
    }
  }
}
