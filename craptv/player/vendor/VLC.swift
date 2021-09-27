////
////  Player.swift
////  Player
////
////  Created by Alex on 17/09/2021.
////

import AppKit
import Combine
import Defaults
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

class PlayerVLC: AbstractPlayer, VLCMediaPlayerDelegate, VLCMediaDelegate,
  VLCMediaThumbnailerDelegate
{
  
  typealias PlayerType = PlayerVLC


  var player: VLCMediaPlayer!

  var playerView: VLCVideoView!

  var media: VLCMedia!

  let center = NotificationCenter.default
  let mainQueue = OperationQueue.main

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

  private var unmuteAfterLoading: Bool = true

  var isLoading: Bool! {
    didSet {
      if self.isLoading {
        self.unmuteAfterLoading = !self.isMuted
        self.player.audio.isMuted = true
      }
      else {
        self.player.audio.isMuted = !self.unmuteAfterLoading
      }
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

  required init(
    _ controller: Player
  ) {
    self.controller = controller
    super.init(controller)
  }

  override func initView(_ view: VideoView) {
    self.playerView = VLCVideoView(frame: view.frame)
    self.playerView.autoresizingMask = [
      NSView.AutoresizingMask.width, NSView.AutoresizingMask.height,
    ]
    self.playerView.fillScreen = true
    self.player = VLCMediaPlayer(videoView: self.playerView)
    self.player.delegate = self
    //    self.controller.size = view.frame.size
    view.addSubview(self.playerView)
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
    self.media.delegate = self
    self.player.media = self.media
    self.isLoading = true
    self.player.play()
    self.controller.display = false
    let thumbnailer = VLCMediaThumbnailer(media: self.media, andDelegate: self)
    thumbnailer?.fetchThumbnail()
  }

  override func stop() {
    self.player.stop()
    self.media = nil
    self.isLoading = false
  }

  func onMediaPlaying() {
    self.loadMetadata()
    let sizep = self.controller.metadata.video.resolution
    logger.debug("on media playing, sizep \(sizep.width)x\(sizep.height)")
    guard sizep.width > 0 || sizep.height > 0 else {
      return
    }
    self.controller.resolution = sizep
    NotificationCenter.default.post(name: .fit, object: sizep)
    self.controller.onStartPlaying()
  }

  override func sizeView(_ newSize: NSSize) {
    logger.debug("VLC setting frame size \(newSize.width)x\(newSize.height)")
    self.playerView.setFrameSize(newSize)
    self.playerView.fillScreen = true
    self.controller.display = true
    self.isLoading = false
  }

  func mediaThumbnailerDidTimeOut(_ mediaThumbnailer: VLCMediaThumbnailer!) {
    logger.debug("thumbnailer timeout")
    self.controller.error = PlayerError(id: .trackFailed, msg: "Kura mi Yanko")
    self.controller.state = .error
    self.isLoading = false
    self.controller.onStopPlaying()
  }

  func mediaThumbnailer(
    _ mediaThumbnailer: VLCMediaThumbnailer!,
    didFinishThumbnail thumbnail: CGImage!
  ) {
    logger.debug(
      "thumbnailer fetch done, \(mediaThumbnailer.thumbnailWidth)x\(mediaThumbnailer.thumbnailHeight)"
    )
    self.onMediaPlaying()
  }

}
