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

class Player: NSObject, PlayerProtocol, ObservableObject {

  @Published var error = PlayerError(id: .null, msg: "")
  @Published var resolution = CGSize(width: 1920, height: 1080)
  @Published var state: PlayerState = .none
  @Published var onTop: Bool = true
  @Published var isFullscreen: Bool = false
  @Published var display: Bool = false
  @Published var opacity: Double = 0.5
  @Published var epgId: String = ""
  @Published var category: Category? = nil
  @Published var icon: String = ""
  @Published var hint: String = ""
  @Published var controlsState: PlayerControlsState = .hidden
  @Published var volumeStage: Int = 1
  @Published var iconSize: NSSize = NSSize(width: 15.0, height: 15.0)
  @Published var size: NSSize = NSSize(width: 12.0, height: 9.0) {
    didSet {
      guard self.size.width * self.size.height > 0 else {
        return
      }
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
      var stage = self.volume / 33
      stage.round(.up)
      self.volumeStage = min(3, max(1, Int(stage)))
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
      if ToggleViews.hideControls.contains(self._contentToggle ?? .none) {
        controlsState = .hidden
      }
      objectWillChange.send()
    }
  }

  private var _contentToggle: ContentToggle?

  var retries: Int = 0
  var retryTask: DispatchWorkItem!
  let MAX_RETIRES: Int = 5

  public var vendorPlayer: AbstractPlayer!

  static let instance = Player()

  override init() {
    super.init()
    self.vendorPlayer = PlayerFFMpeg(self)
  }

  func initView(_ view: VideoView) {
    self.vendorPlayer.initView(view)
  }

  func play(_ stream: Stream) {
    NotificationCenter.default.post(name: .changeStream, object: stream)
    DispatchQueue.main.async {
      self.metadataState = .loading
      self.metadata = StreamInfo.Metadata(
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

  }

  func retry() {
    if self.stream != nil {
      self.play(self.stream)
    }
  }

  func stop() {
    self.state = .stopped
    self.metadata = StreamInfo.Metadata(
      video: StreamInfo.Video(),
      audio: StreamInfo.Audio()
    )
    self.vendorPlayer.stop()
    self.display = false
  }

  func next() async {
    DispatchQueue.main.async {
      guard self.stream != nil else {
        return
      }
      guard let stream = self.getNextPrevStream(.ascending) else {
        return self.play(self.stream)
      }
      self.play(stream)
    }

  }

  func prev() async {

    DispatchQueue.main.async {
      guard self.stream != nil else {
        return
      }
      guard let stream = self.getNextPrevStream(.descending) else {
        return self.play(self.stream)
      }
      self.play(stream)

    }

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
      self.volume = max(0, min(self.volume + parameter.value, 100))
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

  private func getNextPrevStream(_ sort: Sorting) -> Stream? {
    guard let cat = Category.get(stream.category_id) as Category? else {
      return nil
    }
    let streams = cat.Streams
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

  func onMetadataLoaded() {
    self.metadataState = .loaded
    size = self.metadata.video.resolution
    guard size.width > 0 && size.height > 0 else {
      self.error = PlayerError(
        id: .trackFailed,
        msg: "Codec incompatible switch to FFMPEG renderer"
      )
      self.state = .error
      return
    }
    DispatchQueue.main.async {
      NotificationCenter.default.post(name: .fit, object: self)
    }
    self.display = true
    self.state = .playing
    self.onStartPlaying()
  }

}
