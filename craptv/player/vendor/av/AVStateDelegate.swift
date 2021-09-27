//
//  AVStateDelegate.swift
//  craptv
//
//  Created by Alex on 31/10/2021.
//

import AVFoundation
import Foundation

extension PlayerAV {

  func onStatusChange(change: [NSKeyValueChangeKey: Any]?) {
    let status: AVPlayerItem.Status
    if let statusNumber = change?[.newKey] as? NSNumber {
      status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
    }
    else {
      status = .unknown
    }

    switch status {
    case .readyToPlay:
      guard self.controller.state != PlayerState.playing else {
        return
      }
      self.loadMetadata()
      let size = self.media.presentationSize
      guard size.width > 0 && size.height > 0 else {
        self.controller.error = PlayerError(
          id: .trackFailed,
          msg: "Codec incompatible switch to VLC renderer"
        )
        self.controller.state = .error
        break
      }
      self.controller.size = self.media.presentationSize
      NotificationCenter.default.post(name: .fit, object: self.media.presentationSize)

      self.controller.display = true
      self.controller.state = .playing
      self.controller.onStartPlaying()
      break
    // Player item is ready to play.
    case .failed:
      self.controller.display = false
      self.controller.error = PlayerError(
        id: .trackFailed,
        msg: self.media.error?.localizedDescription ?? "kira mi qnko"
      )
      self.controller.state = .error
      break
    // Player item failed. See error.
    case .unknown: break
    // Player item is not yet ready.
    @unknown default:
      logger.debug(">>>> iunnkopwn player state \(status.rawValue)")
    }
  }

  func onSizeChange(change: [NSKeyValueChangeKey: Any]?) {
  }

  override func observeValue(
    forKeyPath keyPath: String?,
    of object: Any?,
    change: [NSKeyValueChangeKey: Any]?,
    context: UnsafeMutableRawPointer?
  ) {

    switch keyPath {
    case #keyPath(AVPlayerItem.presentationSize):
      self.onSizeChange(change: change)
    case #keyPath(AVPlayerItem.status):
      self.onStatusChange(change: change)
    default:
      super.observeValue(
        forKeyPath: keyPath,
        of: object,
        change: change,
        context: context
      )
    }
  }
}
