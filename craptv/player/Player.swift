//
//  Player.swift
//  Player
//
//  Created by Alex on 17/09/2021.
//

import AppKit
import Combine
import Defaults
import SwiftUI

enum Sorting {
  case ascending, descending
}

enum PlayerState {
  case opening, playing, stopped, error, retry
}

enum MetadataState {
  case loading, loaded
}

struct PlayerError: Error, Identifiable, Equatable {
  var id: Errors

  enum Errors {
    case deviceLoad
    case accessDenied
    case unexpected
    case trackFailed
    case retrying
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
    var channels: Int = 0
    var rate: Int = 0
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
  
  var volume: Float { get set }

  var isMuted: Bool { get set }

  func play(_ stream: Stream)

  func stop()

  func initView(_ view: VideoView)

  func sizeView(_ newSize: NSSize)

  func deInitView()

  static var icon: String { get }

  static var hint: String { get }
  
  static var id: PlayVendor { get }

  init(_ controller: Player)

}

protocol PlayerProtocol: ObservableObject {
    
  var error: PlayerError { get set }
  var resolution: CGSize { get set }
  var state: PlayerState { get set }
  var onTop: Bool { get set }
  var isFullscreen: Bool { get set }
  var display: Bool { get set }
  var opacity: Double { get set }
  var size: NSSize! { get set }
  var stream: Stream! { get set }
  var isMuted: Bool { get set }
  var epgId: String { get set }
  var category: Category? { get set }
  var contentToggle: ContentToggle? { get set }
  var volume: Float { get set }
  var showControls: Bool { get set }
  var icon: String { get set }
  var hint: String { get set }
  var metadata: StreamInfo.Metadata { get set }
  var vendor: PlayVendor { get set }

  func initView(_ view: VideoView)

  func play(_ stream: Stream)

  func retry()

  func stop()

  func prev() async

  func next() async

  func onStartPlaying()

  func onStopPlaying()

  func onAudioCommand(_ parameter: Audio.Parameter)
}

extension Notification.Name {
  static let vendorChange = Notification.Name("renderer_switch")
}

enum PlayVendor: Int, DefaultsSerializable {
  case vlc = 2
  case avfoundation = 1
  case unknown = 0
}

enum PlayVendorDesc {

}

class Player: NSObject, PlayerProtocol, ObservableObject {
  
  @Published var error = PlayerError(id: .null, msg: "")
  @Published var resolution = CGSize(width: 1920, height: 1080)
  @Published var state: PlayerState = .opening
  @Published var onTop: Bool = true
  @Published var isFullscreen: Bool = false
  @Published var display: Bool = false
  @Published var opacity: Double = 0.5
  @Published var epgId: String = ""
  @Published var category: Category? = nil
  @Published var icon: String = ""
  @Published var hint: String = ""
  @Published var showControls: Bool = false
  @Published var size: NSSize! {
    didSet {
      self.vendorPlayer.sizeView(self.size)
    }
  }
  @Published var stream: Stream!
  @Published var isMuted: Bool = false {
    didSet {
      self.vendorPlayer.isMuted.toggle()
    }
  }
  @Published var metadata: StreamInfo.Metadata = StreamInfo.Metadata(
    video: StreamInfo.Video(),
    audio: StreamInfo.Audio()
  )
  @Published var metadataState: MetadataState = .loading

  var volume: Float = 100.0 {
    didSet {
      self.vendorPlayer.volume = self.volume
      Defaults[.volume] = self.volume
      objectWillChange.send()
    }
  }

  var contentToggle: ContentToggle? {
    get {
      self._contentToggle
    }
    set {
      self._contentToggle = newValue == self._contentToggle ? nil : newValue
      objectWillChange.send()
    }
  }

  private var _contentToggle: ContentToggle?

  var retries: Int = 0
  var retryTask: DispatchWorkItem!
  let MAX_RETIRES: Int = 5

  private var vendorPlayer: AbstractPlayer!
  var vendor: PlayVendor

  static let instance = Player()

  override init() {
    let selectedVendor = Defaults[.vendor]
    vendor = selectedVendor
    super.init()
    self.switchVendor(selectedVendor, boot: true)
  }

  func switchVendor(_ vendor: PlayVendor, boot: Bool = false) {
    if self.vendorPlayer != nil {
      self.stop()
      self.vendorPlayer.deInitView()
    }
    switch vendor {
    case .vlc:
      self.vendorPlayer = PlayerVLC(self)
    case .avfoundation:
      self.vendorPlayer = PlayerAV(self)
    case .unknown:
      fatalError()
    }
  }

  func initView(_ view: VideoView) {
    self.vendorPlayer.initView(view)
  }

  func play(_ stream: Stream) {
    NotificationCenter.default.post(name: .changeStream, object: stream)

    self.metadataState = .loading
    metadata = StreamInfo.Metadata(
      video: StreamInfo.Video(),
      audio: StreamInfo.Audio()
    )
    self.state = .opening
    self.retryTask?.cancel()
    if self.state == .retry {
      self.retries = 0
    }
    self.stream = stream
    self.epgId = stream.epg_channel_id
    self.category = Category.get(stream.category_id)
    self.vendorPlayer.play(stream)
  }

  func retry() {
    if self.stream != nil {
      self.play(self.stream)
    }
  }

  func stop() {
    self.state = .stopped
    metadata = StreamInfo.Metadata(
      video: StreamInfo.Video(),
      audio: StreamInfo.Audio()
    )
    self.vendorPlayer.stop()
    self.display = false
  }

  func next() async {
    guard self.stream != nil else {
      return
    }
    guard let stream = await self.getNextPrevStream(.ascending) else {
      return self.play(self.stream)
    }
    self.play(stream)
  }

  func prev() async {
    guard self.stream != nil else {
      return
    }
    guard let stream = await self.getNextPrevStream(.descending) else {
      return self.play(stream)
    }
    self.play(stream)

  }

  func onStartPlaying() {
    self.retries = 0
    self.state = .playing
    NotificationCenter.default.post(name: .startPlaying, object: self.stream)
  }

  func onStopPlaying() {

    if self.state == .stopped {
      return
    }

    guard self.state == .opening else {
      return
    }

    guard self.retries < self.MAX_RETIRES else {
      return
    }
    logger.info("on stop playing")
    self.state = .retry
    self.error = PlayerError(id: .retrying, msg: "Retrying \(self.retries + 1)/5")
    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: self.getRetryTask())
  }
  
  private func getRetryTask() -> DispatchWorkItem {
    if self.retryTask != nil && !self.retryTask.isCancelled {
      self.retryTask.cancel()
    }
    self.retryTask = DispatchWorkItem {
      self.retry()
      self.retries += 1
      logger.info("\retrying")
    }
    return self.retryTask
  }

  func onAudioCommand(_ parameter: Audio.Parameter) {
    switch parameter.command {
    case .volume_offset:
      self.volume = max(0, min(self.volume + parameter.value, 200))
      NotificationCenter.default.post(
        name: .audioCommandResult,
        object: Audio.Result(command: .volume_set, value: self.volume)
      )
      break

    case .volume_set:
      self.volume = parameter.value
      NotificationCenter.default.post(
        name: .audioCommandResult,
        object: Audio.Result(command: .volume_set, value: self.volume)
      )
    }
  }

  private func getNextPrevStream(_ sort: Sorting) async -> Stream? {
    guard let cat = Category.get(stream.category_id) as Category? else {
      return nil
    }
    let streams = await cat.fetchStreams()
    if let idx = streams.firstIndex(where: { $0.stream_id == self.stream.stream_id }) {
      let resIdx =
        sort == .ascending ? streams.index(after: idx) : streams.index(before: idx)
      guard resIdx == -1 || streams.count <= resIdx else {
        return streams[resIdx] as? Stream
      }
    }

    return nil
  }



  func deinitView() {
    fatalError()
  }

}
