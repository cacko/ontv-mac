//
//  PlayerProtocol.swift
//  craptv
//
//  Created by Alex on 02/11/2021.
//

import Defaults
import Foundation
import KSPlayer
import SwiftUI

enum PlayerState {
  case notSetURL
  case readyToPlay
  case buffering
  case bufferFinished
  case paused
  case playedToTheEnd
  case error
  case retry
  case opening
  case playing
  case stopped
  case none
}

enum Sorting {
  case ascending, descending
}

enum MetadataState {
  case loading, loaded
}

enum VendorFeature {
  case volume
}

struct PlayerError: Error, Identifiable, Equatable {
  var id: Errors

  enum Errors {
    case deviceLoad
    case accessDenied
    case unexpected
    case trackFailed
    case retrying
    case timeout
    case unknown
    case null
  }

  //    let kind: Errors
  let msg: String
}

enum StreamInfo {
  struct Video {
    var codec: String = "Unknown"
    var resolution: NSSize = NSSize(width: 0, height: 0)
  }
  struct Audio {
    var codec: String = "Unknown"
    var bitrate: String = ""
  }
  struct Metadata {
    var video: Video
    var audio: Audio
  }
}

protocol PlayerView: NSResponder, NSAnimatablePropertyContainer, NSUserInterfaceItemIdentification,
  NSDraggingDestination, NSAppearanceCustomization, NSAccessibilityElementProtocol,
  NSAccessibilityProtocol
{}

protocol PlayerVendorProtocol {
//  var volume: Float { get set }
//  var isMuted: Bool { get set }
  init(_ controller: Player)
func play(_ stream: Stream)
  func reconnect()

  func stop()
  func initView(_ view: VideoView)
  func sizeView(_ newSize: NSSize)
  func deInitView()
}

enum PlayerControlsState {
  case hidden, visible, hovered, always
}

protocol PlayerProtocol: ObservableObject {
  var error: PlayerError { get set }
  var state: PlayerState { get set }
  var onTop: Bool { get set }
  var isFullscreen: Bool { get set }
  var display: Bool { get set }
  var opacity: Double { get set }
  var size: NSSize { get set }
  var iconSize: NSSize { get set }
  var stream: Stream! { get set }
//  var isMuted: Bool { get set }
  var epgId: String { get set }
  var category: Category? { get set }
  var contentToggle: ContentToggle? { get set }
//  var volume: Float { get set }
  var controlsState: PlayerControlsState { get set }
  var icon: String { get set }
  var hint: String { get set }
  var metadata: StreamInfo.Metadata { get set }

  func initView(_ view: VideoView)
  func play(_ stream: Stream)
  func reconnect()
  func retry()
  func stop()
  func prev() async
  func next() async
  func onStartPlaying()
  func onStopPlaying()
  func onAudioCommand(_ parameter: Audio.Parameter)
}
