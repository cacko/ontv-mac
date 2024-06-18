//
//  AppDelegate.swift
//  AppDelegate
//
//  Created by Alex on 04/10/2021.
//

import CoreStore
import Defaults
import Foundation
import Settings
import AppKit

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

extension Settings.PaneIdentifier {
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
  
  var apiLoaded = false
  
  var playerLoaded = false

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
    super.init()
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    let app: NSApplication = notification.object as! NSApplication
    let crapwindow = app.windows.last
    crapwindow?.resignKey()
    crapwindow?.resignMain()
    crapwindow?.resignFirstResponder()
    crapwindow?.setIsVisible(false)
    crapwindow?.close()

    
    let contentViewController = MainHostingController(rootView: ContentView())

    window.center()
    window.acceptsMouseMovedEvents = true
    window.setFrameAutosaveName("Main Window")
    window.contentView = contentViewController.view
    window.contentAspectRatio = fixedRatio
    window.collectionBehavior = .fullScreenPrimary
    window.backgroundColor = .black
    window.hasShadow = false
    windowController.window?.delegate = windowController
    windowController.showWindow(self)
    window.makeKeyAndOrderFront(nil)
    window.makeMain()
    window.becomeFirstResponder()
    

    window.isFloating = Defaults[.isFloating]
    Task.init {
      await API.Adapter.login()
    }
    player.iconSize = NSSize(width: window.frame.width / 30, height: window.frame.width / 30)
    observe()
    
  }

  let StreamsPreferencesView: () -> SettingsPane = {
    let paneView = Settings.Pane(
      identifier: .streams,
      title: "Streams",
      toolbarIcon: NSImage(
        systemSymbolName: "person.crop.circle",
        accessibilityDescription: "Streams preferences"
      )!
    ) {
      PreferencesView.User()
    }

    return Settings.PaneHostingController(pane: paneView)
  }

  let LeaguesPreferencesView: () -> SettingsPane = {
    let paneView = Settings.Pane(
      identifier: .leagues,
      title: "Leagues",
      toolbarIcon: NSImage(
        systemSymbolName: "sportscourt",
        accessibilityDescription: "Preffered leagues"
      )!
    ) {
      PreferencesView.Leagues()
    }

    return Settings.PaneHostingController(pane: paneView)
  }

  private lazy var preferences: [SettingsPane] = [
    StreamsPreferencesView(),
    LeaguesPreferencesView(),
  ]

  lazy var preferencesWindowController = SettingsWindowController(
    panes: preferences,
    style: .segmentedControl,
    animated: true,
    hidesToolbarForSingleItem: true
  )

  
  func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    return NSApplication.TerminateReply.terminateNow
  }
}
