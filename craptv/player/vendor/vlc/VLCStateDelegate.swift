//
//  VLCStateDelegate.swift
//  craptv
//
//  Created by Alex on 31/10/2021.
//

import Foundation

extension PlayerVLC {
  func mediaPlayerStateChanged(_ aNotification: Notification?) {

    switch self.media.state {
    case VLCMediaState.playing:
      logger.debug("media playing")
      break
    case VLCMediaState.buffering:
      logger.debug("media buffering")
    case VLCMediaState.error:
      logger.debug("media error")
      self.controller.error = PlayerError(id: .trackFailed, msg: "ff")
      self.controller.state = .error
      self.isLoading = false

      return
    case VLCMediaState.nothingSpecial:
      logger.debug("media nothing special")
    @unknown default:
      logger.debug("state unknown")
    }

    switch self.player.state {
    case VLCMediaPlayerState.error:
      logger.debug("media error")
      self.controller.error = PlayerError(id: .trackFailed, msg: "ff")
      self.controller.state = .error
      self.isLoading = false
    case VLCMediaPlayerState.stopped:
      guard self.controller.state != .stopped else {
        break
      }
      self.controller.state = .error
      self.controller.error = PlayerError(id: .trackFailed, msg: "Can't play")
      self.controller.onStopPlaying()
      self.isLoading = false

      break
    case VLCMediaPlayerState.playing:
      logger.debug("player playing")
    case VLCMediaPlayerState.buffering:
      logger.debug("player buffering")
    case VLCMediaPlayerState.ended:
      logger.debug("player ended")
    case VLCMediaPlayerState.esAdded:
      logger.debug("player stream added")
    default:
      break
    }
  }

}
