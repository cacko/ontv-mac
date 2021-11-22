//
//  AppDelegate.swift
//  AppDelegate
//
//  Created by Alex on 04/10/2021.
//

import CoreStore
import Defaults
import Foundation
import Preferences
import SwiftUI

enum WindowController {
  case main, prefences
}

extension NSWindow.StyleMask {
  static var defaultWindow: NSWindow.StyleMask {
    var styleMask: NSWindow.StyleMask = .closable
    styleMask.formUnion(.fullSizeContentView)
    styleMask.formUnion(.resizable)
    return styleMask
  }
}

extension Preferences.PaneIdentifier {
  static let streams = Self("streams")
  static let urlinput = Self("urlinput")
  static let leagues = Self("leagues")
}

extension CATransaction {
  static func disableAnimations(_ completion: () -> Void) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    completion()
    CATransaction.commit()
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  var window: MainWindow

  let windowController: MainWindowController

  var fixedRatio = NSSize(width: 1680, height: 1050)

  var initAppSize = NSSize(width: 800, height: 450)

  var lastOffset: CGFloat = 1.0

  var player: Player

  var menu: NSMenu!
  
  var fadeTask: DispatchWorkItem!

  override init() {
    window = MainWindow(
      contentRect: NSRect(x: 0, y: 0, width: 800, height: 450),
      styleMask: [.closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered,
      defer: true
    )
    windowController = MainWindowController(
      window: window
    )
    player = Player.instance
    player.volume = Defaults[.volume]
    super.init()
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    let app: NSApplication = notification.object as! NSApplication
    let crapwindow = app.windows.first
    crapwindow?.resignKey()
    crapwindow?.resignMain()
    crapwindow?.resignFirstResponder()
    crapwindow?.setIsVisible(false)
    app.removeWindowsItem(crapwindow!)

    let contentViewController = MainHostingController(rootView: ContentView())
    observe()
    window.center()
    window.acceptsMouseMovedEvents = true
    window.setFrameAutosaveName("Main Window")
    window.contentView = contentViewController.view
    window.contentAspectRatio = fixedRatio
    window.collectionBehavior = .fullScreenPrimary
    window.backgroundColor = .black
    window.hasShadow = false
    window.showsResizeIndicator = true
    windowController.window?.delegate = windowController
    windowController.showWindow(self)
    window.makeKeyAndOrderFront(nil)
    window.makeMain()
    window.becomeFirstResponder()
    menu = Menu()
    #if DEBUG
    window.isFloating = false
    #else
    window.isFloating = Defaults[.isFloating]
    #endif
    Task.init {
      await API.Adapter.login()
    }
  }

  let StreamsPreferencesView: () -> PreferencePane = {
    let paneView = Preferences.Pane(
      identifier: .streams,
      title: "Streams",
      toolbarIcon: NSImage(
        systemSymbolName: "person.crop.circle",
        accessibilityDescription: "Streams preferences"
      )!
    ) {
      PreferencesView.User()
    }

    return Preferences.PaneHostingController(pane: paneView)
  }
  
  let LeaguesPreferencesView: () -> PreferencePane = {
    let paneView = Preferences.Pane(
      identifier: .leagues,
      title: "Leagues",
      toolbarIcon: NSImage(
        systemSymbolName: "sportscourt",
        accessibilityDescription: "Preffered leagues"
      )!
    ) {
      PreferencesView.Leagues()
    }
    
    return Preferences.PaneHostingController(pane: paneView)
  }

  private lazy var preferences: [PreferencePane] = [
    StreamsPreferencesView(),
    LeaguesPreferencesView()
  ]

  lazy var preferencesWindowController = PreferencesWindowController(
    preferencePanes: preferences,
    style: .segmentedControl,
    animated: true,
    hidesToolbarForSingleItem: true
  )

  func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    return NSApplication.TerminateReply.terminateNow
  }
}
