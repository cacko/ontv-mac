//
//  FFMpegPlayerView.swift
//  craptv
//
//  Created by Alex on 01/11/2021.
//

import AVFoundation
import AppKit
import CoreMedia
import Foundation
import KSPlayer
import Libavformat

class FFMpegPlayerView: VideoPlayerView {

  private let controller: Player

  init(
    _ controller: Player
  ) {
    self.controller = controller
    super.init(frame: .zero)
  }

  override func customizeUIComponents() {
    super.customizeUIComponents()
    navigationBar.isHidden = true
    toolBar.isHidden = true
    toolBar.timeSlider.isHidden = true
    toolBar.removeFromSuperview()
    loadingIndector.removeFromSuperview()
    seekToView.isHidden = true
    seekToView.removeFromSuperview()
    srtControl.view.removeFromSuperview()
    replayButton.isHidden = true
    replayButton.removeFromSuperview()
  }

  override func player(layer _: KSPlayerLayer, finish error: Error?) {
    guard let error = error as Error? else {
      return
    }
    if error.localizedDescription == "unknown" {
      debugPrint("FAKE ERROR")
      return
    }
    self.onError(PlayerError(id: .trackFailed, msg: error.localizedDescription))
    
  }

  override open func player(layer: KSPlayerLayer, state: KSPlayerState) {
    super.player(layer: layer, state: state)
    
    guard state == .error, let player = layer.player else {
      return
    }
    guard state == .bufferFinished, let player = layer.player else {
      return
    }

    guard let videoTrack = player.tracks(mediaType: .video).first as MediaPlayerTrack? else {
      return
    }

    Player.instance.metadata.video = StreamInfo.Video(
      codec: videoTrack.codecType.description,
      resolution: videoTrack.naturalSize
    )

    DispatchQueue.main.async {
      Player.instance.size = videoTrack.naturalSize
      NotificationCenter.default.post(name: .fit, object: videoTrack.naturalSize)
    }

    guard let audioTrack = player.tracks(mediaType: .audio).first else {
      return
    }

    Player.instance.metadata.audio = StreamInfo.Audio(
      codec: audioTrack.codecType.description,
      channels: 2,
      rate: 44100
    )
    DispatchQueue.main.async {
      Player.instance.metadataState = .loaded
    }
  }
  
  func onError(_ error: PlayerError) {
    DispatchQueue.main.async {
      self.controller.error = error
      self.controller.state = .error
    }
  }
}
