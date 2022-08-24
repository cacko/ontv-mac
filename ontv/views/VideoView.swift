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
  static let changescreen = NSNotification.Name("change_screen")
}

class VideoView: NSView {
  var player = Player.instance
  let current_screen: NSScreen! = nil

  func postInit() {
    player.initView(self)

    let center = NotificationCenter.default
    let mainQueue = OperationQueue.main

    center.addObserver(forName: .fit, object: nil, queue: mainQueue) { note in
      guard !self.player.isFullscreen else {
        return
      }
      guard let frameSize = self.frame.size as NSSize? else {
        return
      }
      let newSize = NSSize(
        width: frameSize.width,
        height: frameSize.width * (1 / self.player.size.aspectRatio)
      )
      self.player.size = newSize
      NotificationCenter.default.post(
        name: .reaspect,
        object: nil
      )
    }

    center.addObserver(forName: .zoomchange, object: nil, queue: mainQueue) { note in
      guard let zoom = note.object as? Video.Zoom else {
        return
      }

      guard let wsize = self.window?.frame.size else {
        return
      }

      guard let screenSize = self.window?.screen?.frame.size else {
        return
      }

      let newSize = wsize.zoom(zoom)

      guard newSize.width > 150 && newSize.width < screenSize.width else {
        return
      }

      self.player.size = wsize.zoom(zoom)
      NotificationCenter.default.post(name: .reaspect, object: nil)
    }
  }


  func initPlayer() {
    player.initView(self)
  }

  override func mouseDown(with event: NSEvent) {
    //    guard event.clickCount < 2 else {
    //      NotificationCenter.default.post(name: .toggleFullscreen, object: nil)
    //      return
    //    }
  }

  override func mouseDragged(with event: NSEvent) {
    window?.performDrag(with: event)
  }

}

struct VideoViewRep: NSViewRepresentable {

  typealias NSViewType = VideoView

  func makeNSView(context: Context) -> VideoView {
      let vv = VideoView()
    vv.postInit()
    return vv
  }

  func updateNSView(_ nsView: VideoView, context: Context) {}


}
