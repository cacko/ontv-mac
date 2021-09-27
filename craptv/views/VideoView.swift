//
//  VideoView.swift
//  VideoView
//
//  Created by Alex on 21/09/2021.
//

import AVFoundation
import Defaults
import SwiftUI

enum Video {
  enum Zoom {
    case expand, shrink
  }
}

extension NSNotification.Name {
  static let reaspect = NSNotification.Name("re_aspect")
  static let zoomchange = NSNotification.Name("zppm_change")
}

class VideoView: NSView {
  var player = Player.instance

  init() {
    super.init(frame: .zero)
    player.initView(self)

    let center = NotificationCenter.default
    let mainQueue = OperationQueue.main

    center.addObserver(forName: .fit, object: nil, queue: mainQueue) { note in
      guard var wsize = self.window?.frame.size else {
        return
      }
      guard let psize = note.object as? NSSize else {
        return
      }
      
      if self.player.isFullscreen {
        wsize = (NSScreen.main?.frame.size)!
        logger.debug("is in fullscreen, size \(wsize.width)x\(wsize.height)")
      }
      let pr = psize.height / psize.width
      let h = wsize.width * pr
      let newSize = NSSize(width: wsize.width, height: h)
      self.setFrameSize(newSize)
      NotificationCenter.default.post(
        name: .reaspect,
        object: newSize
      )
    }

    center.addObserver(forName: .zoomchange, object: nil, queue: mainQueue) { note in
      guard let zoom = note.object as? Video.Zoom else {
        return
      }

      guard let wsize = self.window?.frame.size else {
        return
      }

      guard wsize.width > 150 || zoom == .expand else {
        return
      }

      guard wsize.width < (NSScreen.main?.frame.width)! || zoom == .shrink else {
        return
      }

      var w: Double = 0

      switch zoom {
      case .shrink:
        w = wsize.width - 50
      case .expand:
        w = wsize.width + 50
      }

      let h = w * wsize.height / wsize.width
      NotificationCenter.default.post(name: .reaspect, object: NSSize(width: w, height: h))
    }

    center.addObserver(forName: .vendorChange, object: nil, queue: mainQueue) {
      note in
      guard let renderer = note.object as? PlayVendor else {
        return
      }
      Defaults[.vendor] = renderer
      self.player.switchVendor(renderer)
      self.player.initView(self)
      if let stream = self.player.stream {
        self.player.play(stream)
      }
    }
  }

  func initPlayer() {
    player.initView(self)
  }

  @available(*, unavailable)
  required init?(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

//  override func viewDidEndLiveResize() {
////    player.size = (window?.frame.size)!
//  }

  override func mouseDown(with event: NSEvent) {
    guard event.clickCount < 2 else {
      NotificationCenter.default.post(name: .toggleFullscreen, object: nil)
      return
    }
  }
}

struct VideoViewRep: NSViewRepresentable {
  typealias NSViewType = VideoView

  func makeNSView(context: Context) -> VideoView {
    VideoView()
  }

  func updateNSView(_ nsView: VideoView, context: Context) {}
}
