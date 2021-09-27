////
////  Player.swift
////  Player
////
////  Created by Alex on 17/09/2021.
////

import AVFoundation
import AVKit
import AppKit
import Combine
import Defaults
import SwiftUI

class PlayerAV: AbstractPlayer, AVPlayerViewDelegate, AVPlayerPlaybackCoordinatorDelegate {

  let controller: Player

  var player: AVPlayer!

  var playerLayer: AVPlayerLayer!

  var media: AVPlayerItem!

  let center = NotificationCenter.default
  let mainQueue = OperationQueue.main

  var playerItemContext = 0

  override var isMuted: Bool {
    get {
      self.player.isMuted
    }
    set {
      self.player.isMuted.toggle()
    }
  }

  override var volume: Float {
    get {
      self.player.volume * 100
    }
    set {
      self.player.volume = max(0, min(newValue / 100, 2))
    }
  }

  private var initialised: Bool = false

  class override var icon: String {
    "avfoundation"
  }

  class override var hint: String {
    "AV Renderer"
  }

  class override var id: PlayVendor {
    PlayVendor.avfoundation
  }

  required init(
    _ controller: Player
  ) {
    self.controller = controller
    super.init(controller)
  }

  override func initView(_ view: VideoView) {
    player = AVPlayer()
    playerLayer = AVPlayerLayer(player: player)
    playerLayer.frame = view.frame
    playerLayer.minificationFilter = .nearest
    playerLayer.magnificationFilter = .nearest
    playerLayer.contentsGravity = .resizeAspectFill
    playerLayer.videoGravity = .resizeAspect
    view.layer = playerLayer
    player.playbackCoordinator.delegate = self
    self.volume = Defaults[.volume]
  }

  override func deInitView() {
    player.pause()
    player.replaceCurrentItem(with: nil)
    player = nil
    playerLayer.removeFromSuperlayer()
  }

  override func play(_ stream: Stream) {

    self.player.volume = max(0, self.volume / 100)

    self.media = AVPlayerItem(url: stream.url)
    self.media.addObserver(
      self,
      forKeyPath: #keyPath(AVPlayerItem.status),
      options: [.old, .new],
      context: &playerItemContext
    )
    self.player.replaceCurrentItem(with: self.media)
    self.player.play()
  }

  override func stop() {
    self.player.pause()
    self.player.replaceCurrentItem(with: nil)
    self.controller.onStopPlaying()
  }
  
}
