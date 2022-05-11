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

class PlayerVLCKit: AbstractPlayer, VLCMediaPlayerDelegate {
  
  let controller: Player
  
  var player: VLCMediaPlayer!
  
  var playerView: VLCVideoView!
  
  var media: VLCMedia!
  
  let center = NotificationCenter.default
  let mainQueue = OperationQueue.main
  
  var playerItemContext = 0
  
  private var displayTask: DispatchSourceTimer!
  
  override var isMuted: Bool {
    get {
//      self.player.audio.isMuted
      return false
    }
    set {
//      self.player.audio.isMuted.toggle()
    }
  }
  
  override var volume: Float {
    get {
//      Float(self.player.audio.volume * 100)
      return 100
    }
    set {
//      self.player?.audio.volume = Int32(max(0, min(newValue / 100, 1)))
    }
  }
  
  private var initialised: Bool = false
  
  override class var vendor: VendorInfo {
    get {
      VendorInfo(
        icon: "vlckit",
        hint: "VLCKint",
        id: .vlckit,
        features: [.volume]
      )
    }
    set {}
  }
  
  let requiredAssetKeys = [
    "playable",
    "availableMetadataFormats",
    "metadata",
    "tracks",
  ]
  
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
  
  
  //    self.waitForResoze()

  
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
  
}
