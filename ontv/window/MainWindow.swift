//
//  MainWindow.swift
//  MainWindow
//
//  Created by Alex on 23/09/2021.
//

import Defaults
import Foundation
import IOKit
import IOKit.pwr_mgt
import SwiftUI

class MainHostingController: NSHostingController<ContentView> {
  var noSleepAssertionID: IOPMAssertionID = 0
  var noSleepReturn: IOReturn?
  let player = Player.instance

  override func viewWillAppear() {
    disableScreenSleep()
  }

  override func viewDidAppear() {
    player.size = view.frame.size
  }

  private func disableScreenSleep(reason: String = "Unknown reason") {
    guard noSleepReturn == nil else { return }
    noSleepReturn = IOPMAssertionCreateWithName(
      kIOPMAssertionTypeNoDisplaySleep as CFString,
      IOPMAssertionLevel(kIOPMAssertionLevelOn),
      reason as CFString,
      &noSleepAssertionID
    )
  }

  private func enableScreenSleep() {
    if noSleepReturn != nil {
      _ = IOPMAssertionRelease(noSleepAssertionID) == kIOReturnSuccess
      noSleepReturn = nil
      return
    }
  }
}

class MainWindowController: NSWindowController, NSWindowDelegate {

  var player = Player.instance

  override func windowDidLoad() {
    super.windowDidLoad()
    window?.delegate = self
  }

  var hideCursorTask: DispatchWorkItem!

  override func mouseMoved(with event: NSEvent) {
    super.mouseMoved(with: event)

    NSCursor.unhide()
        
    guard self.player.controlsState != .always else {
      return
    }
    
    guard event.locationInWindow.y < 200 else {
      return
    }

    if ToggleViews.hideControls.contains(self.player.contentToggle ?? .none) == false {
      player.controlsState = .visible
    }

    let task = self.getHideCursorTask()

    guard player.controlsState == .visible else {
      return
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: task)
  }

  private func getHideCursorTask() -> DispatchWorkItem {
    if self.hideCursorTask != nil {
      self.hideCursorTask.cancel()
    }
    self.hideCursorTask = DispatchWorkItem {
      guard self.player.contentToggle != .search else {
        return
      }
      self.player.controlsState = .hidden

      guard let win = self.window as? MainWindow else {
        return
      }

      guard win.isFullScreen else {
        return
      }
      NSCursor.hide()

    }
    return self.hideCursorTask
  }
  

  func windowDidChangeScreen(_ notification: Notification) {

    let win = notification.object as! NSWindow
    let swin = self.window as! MainWindow
    swin.current_screen = win.screen! as NSScreen
  }

  func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
    guard let win = self.window as? MainWindow else {
      return frameSize
    }
    if win.isFullScreen {
      let ss = NSScreen.main?.frame.size
      self.player.iconSize = NSSize(width: ss!.width / 30, height: ss!.width / 30)
    }
    else {
      self.player.iconSize = NSSize(width: frameSize.width / 30, height: frameSize.width / 30)
    }
    return frameSize
  }
  
  func windowDidBecomeKey(_ notification: Notification) {
    _ = Menu()
  }
  

}

class MainWindow: NSWindow {
  let player = Player.instance
  var current_screen: NSScreen? = nil

  override var canBecomeMain: Bool {
    true
  }
  
  override var canBecomeKey: Bool {
    true
  }
  
  var isFullScreen = false {
    didSet {
      self.toggleFullScreen(self)
      player.isFullscreen = isFullScreen
      if isFullScreen {
        self.player.size = (NSScreen.main?.frame.size)!
        isFloating = isFullScreen
        NSCursor.hide()
      }
      else {
        NSCursor.unhide()
        self.player.size = self.frame.size
      }
    }
  }

  var isFloating = false {
    didSet {
      guard isFullScreen else {
        level = isFloating ? .floating : .normal
        player.onTop = isFloating
        Defaults[.isFloating] = isFloating
        return
      }
    }
  }

  func reaspectPosition() {
    guard self.current_screen != nil else {
      self.current_screen = NSScreen.main
      return
    }
    let screenSize = self.current_screen!.frame.size
    let or4igibn = self.current_screen?.frame.origin
    let screenRect = NSRect(
      x: or4igibn!.x,
      y: or4igibn!.y,
      width: screenSize.width,
      height: screenSize.height
    )
    let framePos = contentRect(forFrameRect: frame)

    guard !screenRect.contains(framePos) else {
      return
    }

    let dx = screenSize.width - (framePos.minX + framePos.width)
    guard dx > 0 else {
      setFrame(framePos.offsetBy(dx: dx, dy: 0), display: true, animate: false)
      return
    }

    guard framePos.minY > 0 else {
      setFrame(framePos.offsetBy(dx: 0, dy: abs(framePos.minY)), display: true, animate: false)
      return
    }
  }
}
