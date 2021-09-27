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

  override func viewWillAppear() {
    disableScreenSleep()
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

    let task = self.getHideCursorTask()
    NSCursor.unhide()

    if self.player.contentToggle != .activityepg {
      player.showControls = true

    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)

  }

  private func getHideCursorTask() -> DispatchWorkItem {
    if self.hideCursorTask != nil {
      self.hideCursorTask.cancel()
    }
    self.hideCursorTask = DispatchWorkItem {
      guard self.player.contentToggle != .search else {
        return
      }
      self.player.showControls = false

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

}

class MainWindow: NSWindow {
  let player = Player.instance

  override var canBecomeMain: Bool {
    true
  }

  var isFullScreen = false {
    didSet {
        self.toggleFullScreen(self)
      player.isFullscreen = isFullScreen
      if isFullScreen {
        isFloating = isFullScreen
        showsResizeIndicator = false
        NSCursor.hide()
      }
      else {
        NSCursor.unhide()
        showsResizeIndicator = true
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
    let screenSize = NSScreen.main?.frame.size
    let screenRect = NSRect(x: 0, y: 0, width: screenSize!.width, height: screenSize!.height)
    let framePos = contentRect(forFrameRect: frame)

    guard !screenRect.contains(framePos) else {
      return
    }

    let dx = screenSize!.width - (framePos.minX + framePos.width)
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
