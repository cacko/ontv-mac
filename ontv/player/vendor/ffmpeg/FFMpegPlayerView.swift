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
    replayButton.isHidden = true
    replayButton.removeFromSuperview()
  }


  override func player(layer playerLayer: KSPlayerLayer, finish error: Error?) {
        

    guard let error = error as NSError? else {
      return
    }
    if error.code == 4 {
      return self.onError(PlayerError(id: .unknown, msg: error.code.string))
    }

    if error.code == 2 {
      return self.onError(PlayerError(id: .timeout, msg: error.code.string))
    }

    self.onError(PlayerError(id: .trackFailed, msg: error.code.string))
  }

  override open func player(layer: KSPlayerLayer, state: KSPlayerState) {
    super.player(layer: layer, state: state)

    guard state == .bufferFinished  else {
      DispatchQueue.main.async {
        switch state {
        case .prepareToPlay:
          self.controller.state = .buffering
          break
        case .buffering:
          self.controller.state = .buffering
          break
        case .bufferFinished:
          self.controller.state = .bufferFinished
          break
        case .paused:
          self.controller.state = .paused
          break
        case .playedToTheEnd:
          self.controller.state = .playedToTheEnd
          break
        case .error:
          //          self.controller.state = .error
          //          let err = layer.player.
          //          self.onError(PlayerError(id: .unknown, msg: err.code.string))
          break
        case .readyToPlay:
          self.controller.state = .readyToPlay
          break
        }
      }
      return
    }

    guard let videoTrack = layer.player.tracks(mediaType: .video).first as MediaPlayerTrack? else {
      return
    }

    Player.instance.metadata.video = StreamInfo.Video(
      codec: videoTrack.description.videoCodec,
      resolution: videoTrack.naturalSize
    )

    DispatchQueue.main.async {
      Player.instance.size = videoTrack.naturalSize
      Player.instance.onMetadataLoaded()
    }

    guard let audioTrack = layer.player.tracks(mediaType: .audio).first else {
      return
    }

    Player.instance.metadata.audio = StreamInfo.Audio(
      codec: audioTrack.description.audioCodec,
      bitrate: audioTrack.bitRate.bitrate
    )
    DispatchQueue.main.async {
      Player.instance.metadataState = .loaded
    }
  }

  func onError(_ error: PlayerError) {
    DispatchQueue.main.async {
      if error.id == .unknown || error.id == .timeout {
        guard let stream = self.controller.stream else {
          self.controller.error = error
          self.controller.state = .error
          return
        }
        self.controller.stop()
        self.controller.play(stream)
      }
      else {
        self.controller.error = error
        self.controller.state = .error
      }
    }
  }
}
