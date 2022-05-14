//
//  VLCStateDelegate.swift
//  craptv
//
//  Created by Alex on 31/10/2021.
//

import Foundation
import VLCKit

extension PlayerVLCKit {
  
  func mediaPlayerStateChanged(_ aNotification: Notification) {
    switch self.player.state {
    case VLCMediaPlayerState.error:
      self.onError(PlayerError(id: .trackFailed, msg: "VLC throw error"))
      return
    case VLCMediaPlayerState.stopped:
      guard self.controller.state != .opening else {
        return
      }
      guard self.controller.state == .stopped else {
        self.controller.retry()
        self.onError(PlayerError(id: .trackFailed, msg: "VLC stopped"))
        return
      }
      self.controller.onStopPlaying()
      return
    case VLCMediaPlayerState.playing:
      logger.debug("player playing")
    case VLCMediaPlayerState.buffering:
      logger.debug("player buffering")
    case VLCMediaPlayerState.ended:
      logger.debug("player ended")
      self.controller.retry()
      break
    case VLCMediaPlayerState.esAdded:
      logger.debug("player stream added")
    default:
      break
    }
  }
  
  func onError(_ error: PlayerError) {
    self.controller.state = .error
    self.controller.error = error
    self.controller.onStopPlaying()
  }
}
