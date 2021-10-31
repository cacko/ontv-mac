////
////  Player.swift
////  Player
////
////  Created by Alex on 17/09/2021.
////

import AppKit
import Combine
import Defaults
import Foundation
import SwiftUI
import VLCKit

enum VLC {
  struct TrackInfo {
    var bitrate: Any?
    var codec: Any?
    var frame_rate_den: Any?
    var frame_rate_num: Any?
    var height: Any?
    var id: Any?
    var level: Any?
    var orientation: Any?
    var profile: Any?
    var projection: Any?
    var sar_den: Any?
    var sar_num: Any?
    var type: Any?
    var width: Any?
  }
}

extension Notification.Name {
  static let vlcResizeDone = NSNotification.Name("vlc_resize_done")
}

class PlayerVLC: AbstractPlayer, VLCMediaPlayerDelegate {

  var player: VLCMediaPlayer!

  var playerView: VLCVideoView!

  var media: VLCMedia!

  let center = NotificationCenter.default
  let mainQueue = OperationQueue.main

  private var masterView: NSView!
  
  private var observer: NSObjectProtocol!

  override var isMuted: Bool {
    get {
      self.player.audio.isMuted
    }
    set {
      self.player.audio.isMuted.toggle()
    }
  }

  override var volume: Float {
    get {
      Float(self.player.audio.volume)
    }
    set {
      self.player.audio.volume = Int32(max(0, min(newValue, 200)))
    }
  }

  class override var icon: String {
    "vlc"
  }

  class override var hint: String {
    "VLC Renderer"
  }

  class override var id: PlayVendor {
    PlayVendor.vlc
  }

  let controller: Player

  private var displayTask: DispatchSourceTimer!

  private var resizeTask: DispatchSourceTimer!

  required init(
    _ controller: Player
  ) {
    self.controller = controller
    super.init(controller)
  }

  override func initView(_ view: VideoView) {
    self.playerView = VLCVideoView(frame: view.frame)
    let mask = NSView.AutoresizingMask([.height, .width])
    self.playerView.autoresizingMask = mask
    self.player = VLCMediaPlayer(videoView: self.playerView)
    self.player.delegate = self
    self.controller.size = view.frame.size
    view.addSubview(self.playerView)
    masterView = view
    self.volume = Defaults[.volume]
    return
  }

  override func deInitView() {
    player.stop()
    media = nil
    player = nil
    playerView.removeFromSuperview()
    playerView = nil
  }

  override func play(_ stream: Stream) {
    self.media = VLCMedia(url: stream.url)
    self.player.media = self.media
    self.player.play()
    self.controller.display = false
    self.waitForDisplay()
  }

  override func stop() {
    self.displayTask.cancel()
    self.player.stop()
    self.media = nil
  }

  func onMediaPlaying() {
    self.displayTask.cancel()
    self.loadMetadata()
    let sizep = self.controller.metadata.video.resolution
    logger.debug("on media playing, sizep \(sizep.width)x\(sizep.height)")
    guard sizep.width > 0 || sizep.height > 0 else {
      return
    }
    DispatchQueue.main.async {
      self.controller.resolution = sizep
    }
    NotificationCenter.default.post(name: .fit, object: sizep)
  }

  override func sizeView(_ newSize: NSSize) {
    logger.debug("VLC setting frame size \(newSize.width)x\(newSize.height)")
    let fs = self.playerView.frame.size
    if fs.equalTo(newSize) {
      let newRandomSize = newSize.getRandom()
      logger.debug(
        "put random size -> \(fs.toResolution())==\(newSize.toResolution()) -> \(newRandomSize.toResolution())"
      )
      self.playerView.setFrameSize(newRandomSize)
    }
    else {
      self.playerView.setFrameSize(newSize)
    }
    self.playerView.fillScreen = true
    self.playerView.invalidateIntrinsicContentSize()
    self.controller.display = true
    self.controller.onStartPlaying()
    guard let mv = self.masterView else {
      return
    }
    print(
      "\(self.playerView.frame.size.toResolution()) -> \(mv.frame.size.toResolution())"
    )
//    self.waitForResoze()
  }

  func waitForDisplay() {
    if displayTask != nil && !displayTask.isCancelled {
      displayTask.cancel()
    }
    displayTask = DispatchSource.makeTimerSource()
    displayTask.schedule(deadline: .now(), repeating: .milliseconds(300))
    displayTask.setEventHandler {
      guard self.player.videoSize.width > 0 else {
        return
      }
      DispatchQueue.main.async {
        self.onMediaPlaying()
      }
    }
    displayTask.activate()
  }

  func waitForResoze() {
    if resizeTask != nil && !resizeTask.isCancelled {
      resizeTask.cancel()
    }
    resizeTask = DispatchSource.makeTimerSource()
    resizeTask.schedule(deadline: .now(), repeating: .milliseconds(300))
    resizeTask.setEventHandler {
      print("\(self.playerView.frame.size)")
      guard self.playerView.frame.size.equalTo(self.controller.size) else {
        return
      }
      DispatchQueue.main.async {
        self.controller.display = true
        self.controller.onStartPlaying()
        print(
          "\(self.playerView.frame.size.toResolution()) -> \(self.player.videoSize.toResolution())"
        )
        self.resizeTask.cancel()
      }
    }
    resizeTask.activate()
  }
}
