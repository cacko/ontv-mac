////
////  Player.swift
////  Player
////
////  Created by Alex on 17/09/2021.
////

import AVFoundation
import AppKit
import Combine
import Defaults
import KSPlayer
import SwiftUI

class PlayerFFMpeg: AbstractPlayer, PlayerControllerDelegate, MediaPlayerDelegate {
  func readyToPlay(player: some KSPlayer.MediaPlayerProtocol) {
    debugPrint("")

  }
  
  func changeLoadState(player: some KSPlayer.MediaPlayerProtocol) {
    debugPrint("")

  }
  
  func changeBuffering(player: some KSPlayer.MediaPlayerProtocol, progress: Int) {
    debugPrint("")
  }
  
  func playBack(player: some KSPlayer.MediaPlayerProtocol, loopCount: Int) {
    debugPrint("")

  }
  
  func finish(player: some KSPlayer.MediaPlayerProtocol, error: Error?) {
    debugPrint("")

  }
  
  func preparedToPlay(player: KSPlayer.MediaPlayerProtocol) {
    debugPrint("")

  }

  func changeLoadState(player: KSPlayer.MediaPlayerProtocol) {
    debugPrint("")

  }

  func changeBuffering(player: KSPlayer.MediaPlayerProtocol, progress: Int) {
    debugPrint("")

  }

  func playBack(player: KSPlayer.MediaPlayerProtocol, loopCount: Int) {
    debugPrint("")

  }

  func finish(player: KSPlayer.MediaPlayerProtocol, error: Error?) {
    self.player = player
  }

  let controller: Player

  var playerView: FFMpegPlayerView!

  var player: MediaPlayerProtocol!

  var media: KSPlayerResource!

  let center = NotificationCenter.default
  let mainQueue = OperationQueue.main

  var playerItemContext = 0

  override var isMuted: Bool {
    get {
      self.player?.isMuted ?? false
    }
    set {
      self.playerView?.playerLayer?.player.isMuted.toggle()
    }
  }

  override var volume: Float {
    get {
      return (self.player?.playbackVolume ?? 0) * 100
    }
    set {
      let newVolume = max(0, min(newValue / 100, 2))
      self.playerView?.playerLayer?.player.playbackVolume = newVolume
    }
  }

  private var initialised: Bool = false

  required init(
    _ controller: Player
  ) {
    self.controller = controller
      KSOptions.firstPlayerType = KSMEPlayer.self
    KSOptions.topBarShowInCase = .none
    KSOptions.logLevel = .panic
    KSOptions.canBackgroundPlay = true
    KSOptions.enableBrightnessGestures = false
    KSOptions.enablePlaytimeGestures = false
    KSOptions.animateDelayTimeInterval = TimeInterval(5)
    super.init(controller)
  }

  override func initView(_ view: VideoView) {
    playerView = FFMpegPlayerView(controller)
    view.addSubview(playerView)
    playerView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      playerView.widthAnchor.constraint(equalTo: view.widthAnchor),
      playerView.heightAnchor.constraint(equalTo: view.heightAnchor),
    ])
  }

  override func deInitView() {
    //    self.playerView.pause()
    //    self.playerView.resetPlayer()
    //    self.playerView.removeFromSuperview()
    //    self.playerView = nil
  }

  var options: KSOptions {
    let header = ["User-Agent": "ontv/\(Bundle.main.buildVersionNumber)"]
    let options = KSOptions()
    options.avOptions = ["AVURLAssetHTTPHeaderFieldsKey": header]
//    options.subtitleDisable = true
    return options
  }

  private func definition(_ stream: Stream) -> KSPlayerResourceDefinition {
    KSPlayerResourceDefinition(
      url: stream.url,
      definition: API.Adapter.username,
      options: options
    )
  }

  override func play(_ stream: Stream) {
    media = KSPlayerResource(url: stream.url)
    controller.media = media
    if (player?.isPlaying) != nil {
      player.replace(url: stream.url, options: self.options)
    } else {
      playerView.set(resource: media)
      playerView.delegate = self
      playerView.play()
    }
  }

  override func reconnect() {
    if (player?.isPlaying) != nil {
      player.replace(url: self.media.definitions[0].url, options: self.options)
      self.controller.onStartPlaying()
    }
  }

  override func stop() {

  }

}
